import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({
    super.key,
    required this.authToken,
    required this.userName,
    required this.isTrainer,
  });

  final String authToken;
  final String userName;
  final bool isTrainer;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    implements HMSUpdateListener, HMSActionResultListener {
  late final HMSSDK _hms;

  HMSPeer? _localPeer;
  HMSVideoTrack? _localVideo;

  HMSPeer? _remotePeer;
  HMSVideoTrack? _remoteVideo;

  bool _micOff = false;
  bool _camOff = false;

  @override
  void initState() {
    super.initState();
    _initAndJoin();
  }

  Future<void> _initAndJoin() async {
    _hms = HMSSDK();
    await _hms.build();
    _hms.addUpdateListener(listener: this);
    _hms.join(config: HMSConfig(authToken: widget.authToken, userName: widget.userName));
  }

  @override
  void dispose() {
    _hms.removeUpdateListener(listener: this);
    _hms.leave();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _hms.leave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Call'),
          actions: [
            IconButton(
              tooltip: 'Switch camera',
              onPressed: () => _hms.switchCamera(hmsActionResultListener: this),
              icon: const Icon(Icons.cameraswitch),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(12),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _Tile(
                    title: _localPeer?.name ?? 'You',
                    track: _localVideo,
                    placeholderIcon: Icons.person,
                  ),
                  _Tile(
                    title: _remotePeer?.name ?? 'Waiting…',
                    track: _remoteVideo,
                    placeholderIcon: Icons.person_outline,
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton.filledTonal(
                      onPressed: _toggleMic,
                      icon: Icon(_micOff ? Icons.mic_off : Icons.mic),
                    ),
                    IconButton.filledTonal(
                      onPressed: _toggleCam,
                      icon: Icon(_camOff ? Icons.videocam_off : Icons.videocam),
                    ),
                    if (widget.isTrainer)
                      FilledButton.tonalIcon(
                        onPressed: _endForAll,
                        icon: const Icon(Icons.stop_circle),
                        label: const Text('End'),
                      )
                    else
                      FilledButton.tonalIcon(
                        onPressed: () {
                          _hms.leave();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.call_end),
                        label: const Text('Leave'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleMic() => _hms.toggleMicMuteState();
  void _toggleCam() => _hms.toggleCameraMuteState();

  Future<void> _endForAll() async {
    final peer = await _hms.getLocalPeer();
    final allowed = peer?.role.permissions.endRoom ?? false;
    if (!allowed) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your 100ms role cannot end the room.')),
      );
      return;
    }
    _hms.endRoom(lock: false, reason: 'Trainer ended the call', hmsActionResultListener: this);
  }

  @override
  void onJoin({required HMSRoom room}) {
    for (final peer in room.peers ?? const <HMSPeer>[]) {
      if (peer.isLocal) {
        _localPeer = peer;
        _localVideo = peer.videoTrack;
      } else {
        _remotePeer = peer;
        _remoteVideo = peer.videoTrack;
      }
    }
    setState(() {});
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    if (update == HMSPeerUpdate.peerJoined && !peer.isLocal) {
      setState(() => _remotePeer = peer);
    }
    if (update == HMSPeerUpdate.peerLeft && !peer.isLocal) {
      setState(() {
        _remotePeer = null;
        _remoteVideo = null;
      });
    }
  }

  @override
  void onTrackUpdate({
    required HMSTrack track,
    required HMSTrackUpdate trackUpdate,
    required HMSPeer peer,
  }) {
    if (peer.isLocal) {
      if (track.kind == HMSTrackKind.kHMSTrackKindAudio && track.source == "REGULAR") {
        _micOff = track.isMute;
      }
      if (track.kind == HMSTrackKind.kHMSTrackKindVideo && track.source == "REGULAR") {
        _camOff = track.isMute;
        _localVideo = track as HMSVideoTrack;
      }
    } else {
      if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
        if (trackUpdate == HMSTrackUpdate.trackRemoved) {
          _remoteVideo = null;
        } else {
          _remoteVideo = track as HMSVideoTrack;
        }
      }
    }
    setState(() {});
  }

  @override
  void onHMSError({required HMSException error}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('HMS error: ${error.message ?? error.description}')),
    );
  }

  @override
  void onRemovedFromRoom({required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {
    if (!mounted) return;
    final msg = hmsPeerRemovedFromPeer.roomWasEnded
        ? 'Room ended: ${hmsPeerRemovedFromPeer.reason}'
        : 'Removed: ${hmsPeerRemovedFromPeer.reason}';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    Navigator.of(context).pop();
  }

  @override
  void onAudioDeviceChanged({
    HMSAudioDevice? currentAudioDevice,
    List<HMSAudioDevice>? availableAudioDevice,
  }) {}

  @override
  void onChangeTrackStateRequest({
    required HMSTrackChangeRequest hmsTrackChangeRequest,
  }) {}

  @override
  void onMessage({required HMSMessage message}) {}

  @override
  void onPeerListUpdate({
    required List<HMSPeer> addedPeers,
    required List<HMSPeer> removedPeers,
  }) {}

  @override
  void onReconnecting() {}
  @override
  void onReconnected() {}
  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}
  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}
  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {}
  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}

  @override
  void onSuccess({
    HMSActionResultListenerMethod methodType = HMSActionResultListenerMethod.unknown,
    Map<String, dynamic>? arguments,
  }) {
    if (methodType == HMSActionResultListenerMethod.endRoom && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void onException({
    HMSActionResultListenerMethod methodType = HMSActionResultListenerMethod.unknown,
    Map<String, dynamic>? arguments,
    required HMSException hmsException,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Action failed: ${hmsException.message ?? hmsException.description}')),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.title,
    required this.track,
    required this.placeholderIcon,
  });

  final String title;
  final HMSVideoTrack? track;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: track == null
                  ? Center(child: Icon(placeholderIcon, size: 48))
                  : HMSVideoView(track: track!),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

