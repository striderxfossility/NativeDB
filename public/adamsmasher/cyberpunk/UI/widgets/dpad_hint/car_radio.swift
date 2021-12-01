
public class CarRadioGameController extends inkHUDGameController {

  private edit let m_radioStationName: inkTextRef;

  private edit let m_songName: inkTextRef;

  private let m_root: wref<inkWidget>;

  private let m_stateChangesBlackboardId: ref<CallbackHandle>;

  private let m_songNameChangeBlackboardId: ref<CallbackHandle>;

  private let m_blackboard: wref<IBlackboard>;

  private let m_animationProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    this.m_blackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().Vehicle);
    this.m_stateChangesBlackboardId = this.m_blackboard.RegisterListenerBool(GetAllBlackboardDefs().Vehicle.VehRadioState, this, n"OnRadioChange");
    this.m_songNameChangeBlackboardId = this.m_blackboard.RegisterListenerName(GetAllBlackboardDefs().Vehicle.VehRadioStationName, this, n"OnSongChange");
    this.m_root = this.GetRootWidget();
    this.m_root.SetVisible(false);
  }

  protected cb func OnUninitialize() -> Bool {
    this.m_blackboard.UnregisterListenerBool(GetAllBlackboardDefs().Vehicle.VehRadioState, this.m_stateChangesBlackboardId);
    this.m_blackboard.UnregisterListenerName(GetAllBlackboardDefs().Vehicle.VehRadioStationName, this.m_songNameChangeBlackboardId);
  }

  protected cb func OnRadioChange(value: Bool) -> Bool {
    if value {
      this.PlayIntroAnimation();
    };
  }

  protected cb func OnSongChange(value: CName) -> Bool {
    inkTextRef.SetText(this.m_songName, GetLocalizedText("UI-Cyberpunk-HUD-Radio-NowPlaying") + ToString(value));
  }

  private final func PlayIntroAnimation() -> Void {
    this.m_root.SetVisible(true);
    this.m_animationProxy = this.PlayLibraryAnimation(n"intro");
    this.m_animationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnOutroAnimFinished");
  }

  protected cb func OnOutroAnimFinished(anim: ref<inkAnimProxy>) -> Bool {
    this.m_root.SetVisible(false);
  }
}
