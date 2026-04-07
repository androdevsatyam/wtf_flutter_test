const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const jwt = require("jsonwebtoken");
const uuid4 = require("uuid4");
const axios = require("axios").default;

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = Number(process.env.PORT || 8787);
const HMS_APP_ACCESS_KEY = process.env.HMS_APP_ACCESS_KEY;
const HMS_APP_SECRET = process.env.HMS_APP_SECRET;
const HMS_TEMPLATE_ID = process.env.HMS_TEMPLATE_ID;

let managementTokenCache = null;

function getManagementToken() {
  if (!HMS_APP_ACCESS_KEY || !HMS_APP_SECRET) {
    throw new Error("Missing HMS_APP_ACCESS_KEY/HMS_APP_SECRET");
  }
  const now = Math.floor(Date.now() / 1000);
  if (managementTokenCache && managementTokenCache.exp > now + 30) {
    return managementTokenCache.token;
  }

  const payload = {
    access_key: HMS_APP_ACCESS_KEY,
    type: "management",
    version: 2,
    iat: now,
    nbf: now,
  };
  const token = jwt.sign(payload, HMS_APP_SECRET, {
    algorithm: "HS256",
    expiresIn: "24h",
    jwtid: uuid4(),
  });
  managementTokenCache = { token, exp: now + 24 * 3600 };
  return token;
}

// NOTE: This is a minimal dev/local token server scaffold.
// For production, mint tokens on a secure backend and never ship secrets to clients.

app.get("/health", (_req, res) => {
  res.json({ ok: true, service: "token_server", ts: Date.now() });
});

/**
 * POST /token
 * Body:
 * {
 *   "roomId": "<100ms room id>",
 *   "userId": "<app user id>",
 *   "role": "member" | "trainer"
 * }
 *
 * Response:
 * { "token": "<hms token string>" }
 */
app.post("/token", async (req, res) => {
  const { roomId, userId, role } = req.body || {};

  if (!roomId || !userId || !role) {
    return res.status(400).json({
      error: "Missing required fields: roomId, userId, role",
    });
  }

  if (!HMS_APP_ACCESS_KEY || !HMS_APP_SECRET) {
    return res.status(500).json({
      error:
        "Server misconfigured: set HMS_APP_ACCESS_KEY and HMS_APP_SECRET in environment",
    });
  }

  const now = Math.floor(Date.now() / 1000);
  const payload = {
    access_key: HMS_APP_ACCESS_KEY,
    room_id: roomId,
    user_id: userId,
    role: role,
    type: "app",
    version: 2,
    iat: now,
    nbf: now,
  };

  const token = jwt.sign(payload, HMS_APP_SECRET, {
    algorithm: "HS256",
    expiresIn: "24h",
    jwtid: uuid4(),
  });

  return res.json({ token });
});

/**
 * POST /rooms
 * Body:
 * { "name": "...", "description": "...", "templateId": "..." }
 *
 * Response:
 * { "roomId": "<100ms room_id>" }
 */
app.post("/rooms", async (req, res) => {
  const { name, description, templateId } = req.body || {};
  if (!name) {
    return res.status(400).json({ error: "Missing required field: name" });
  }
  if (!HMS_APP_ACCESS_KEY || !HMS_APP_SECRET) {
    return res.status(500).json({
      error:
        "Server misconfigured: set HMS_APP_ACCESS_KEY and HMS_APP_SECRET in environment",
    });
  }

  const tpl = templateId || HMS_TEMPLATE_ID;
  if (!tpl) {
    return res.status(500).json({
      error:
        "Missing templateId. Provide templateId in request body or set HMS_TEMPLATE_ID env var.",
    });
  }

  try {
    const mgmt = getManagementToken();
    const api = axios.create({
      baseURL: "https://api.100ms.live/v2",
      timeout: 60000,
      headers: {
        Authorization: `Bearer ${mgmt}`,
        Accept: "application/json",
        "Content-Type": "application/json",
      },
    });

    const response = await api.post("/rooms", {
      name,
      description: description || "",
      template_id: tpl,
    });

    const roomId = response.data?.id;
    if (!roomId) {
      return res.status(500).json({ error: "Unexpected 100ms response" });
    }
    return res.json({ roomId });
  } catch (e) {
    const status = e?.response?.status;
    const data = e?.response?.data;
    return res.status(500).json({
      error: "Failed to create room via 100ms API",
      status,
      data,
    });
  }
});

app.listen(PORT, () => {
  // eslint-disable-next-line no-console
  console.log(`[token_server] listening on http://localhost:${PORT}`);
});

