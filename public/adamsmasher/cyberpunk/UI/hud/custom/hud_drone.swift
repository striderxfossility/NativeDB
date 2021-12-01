
public class hudDroneController extends inkHUDGameController {

  private edit let m_Date: inkTextRef;

  private edit let m_Timer: inkTextRef;

  private edit let m_CameraID: inkTextRef;

  private let m_scanBlackboard: wref<IBlackboard>;

  private let m_psmBlackboard: wref<IBlackboard>;

  private let m_PSM_BBID: ref<CallbackHandle>;

  private let m_root: wref<inkCompoundWidget>;

  private let m_currentZoom: Float;

  private let currentTime: GameTime;

  protected cb func OnInitialize() -> Bool {
    let ownerObject: ref<GameObject>;
    this.m_scanBlackboard = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Scanner);
    if IsDefined(this.m_scanBlackboard) {
    };
    this.m_root = this.GetRootWidget() as inkCompoundWidget;
    ownerObject = this.GetOwnerEntity() as GameObject;
    this.currentTime = GameInstance.GetTimeSystem(ownerObject.GetGame()).GetGameTime();
    inkTextRef.SetText(this.m_Timer, ToString(GameTime.Hours(this.currentTime)) + ":" + ToString(GameTime.Minutes(this.currentTime)) + ":" + ToString(GameTime.Seconds(this.currentTime)));
    inkTextRef.SetText(this.m_Date, "05-13-2077");
    inkTextRef.SetText(this.m_CameraID, "Story-base-gameplay-gui-widgets-camera_hud-hud_camera-_localizationString3");
  }

  protected cb func OnUninitialize() -> Bool;

  protected cb func OnPlayerAttach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_psmBlackboard = this.GetPSMBlackboard(playerPuppet);
    if IsDefined(this.m_psmBlackboard) {
      this.m_PSM_BBID = this.m_psmBlackboard.RegisterDelayedListenerFloat(GetAllBlackboardDefs().PlayerStateMachine.ZoomLevel, this, n"OnZoomChange");
    };
  }

  protected cb func OnPlayerDetach(playerPuppet: ref<GameObject>) -> Bool {
    this.m_psmBlackboard.UnregisterDelayedListener(GetAllBlackboardDefs().PlayerStateMachine.ZoomLevel, this.m_PSM_BBID);
  }

  protected cb func OnZoomChange(evt: Float) -> Bool {
    this.m_currentZoom = evt;
  }
}
