
public class JukeboxBigGameController extends DeviceInkGameControllerBase {

  private let m_onTogglePlayListener: ref<CallbackHandle>;

  protected func RegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.RegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      this.m_onTogglePlayListener = blackboard.RegisterListenerBool(this.GetOwner().GetBlackboardDef() as JukeboxBlackboardDef.IsPlaying, this, n"OnTogglePlay");
    };
  }

  protected func UnRegisterBlackboardCallbacks(blackboard: ref<IBlackboard>) -> Void {
    this.UnRegisterBlackboardCallbacks(blackboard);
    if IsDefined(blackboard) {
      blackboard.UnregisterListenerBool(this.GetOwner().GetBlackboardDef() as JukeboxBlackboardDef.IsPlaying, this.m_onTogglePlayListener);
    };
  }

  protected cb func OnTogglePlay(value: Bool) -> Bool {
    this.ResolveAnimState(value);
  }

  public func Refresh(state: EDeviceStatus) -> Void {
    if Equals(state, EDeviceStatus.ON) {
      this.ResolveAnimState(this.GetBlackboard().GetBool(this.GetOwner().GetBlackboardDef() as JukeboxBlackboardDef.IsPlaying));
    };
    this.Refresh(state);
  }

  protected final func ResolveAnimState(isPlaying: Bool) -> Void {
    if isPlaying {
      this.TriggerAnimationByName(n"bar1", EInkAnimationPlaybackOption.PLAY);
    } else {
      this.TriggerAnimationByName(n"bar1", EInkAnimationPlaybackOption.STOP);
      this.TriggerAnimationByName(n"bar1", EInkAnimationPlaybackOption.PLAY, this.CreatePlaybackOverrideData());
    };
  }

  private final func CreatePlaybackOverrideData() -> ref<PlaybackOptionsUpdateData> {
    let playbackOptionsOverrideData: ref<PlaybackOptionsUpdateData> = new PlaybackOptionsUpdateData();
    playbackOptionsOverrideData.m_playbackOptions.fromMarker = n"loop_end";
    playbackOptionsOverrideData.m_playbackOptions.toMarker = n"pause_end";
    playbackOptionsOverrideData.m_playbackOptions.loopInfinite = false;
    playbackOptionsOverrideData.m_playbackOptions.loopType = IntEnum(0l);
    return playbackOptionsOverrideData;
  }

  protected func GetOwner() -> ref<Device> {
    return this.GetOwnerEntity() as Device;
  }
}
