
public class NetworkAreaController extends MasterController {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class NetworkAreaControllerPS extends MasterControllerPS {

  private let m_isActive: Bool;

  private let m_visualizerID: Uint32;

  private persistent let m_hudActivated: Bool;

  private persistent let m_currentlyAvailableCharges: Int32;

  private persistent let m_maxAvailableCharges: Int32;

  protected func Initialize() -> Void {
    this.Initialize();
  }

  public final const func AreaEntered() -> Void {
    let activationEvent: ref<NetworkAreaActivationEvent> = new NetworkAreaActivationEvent();
    activationEvent.enable = true;
    this.QueuePSEvent(this.GetID(), this.GetClassName(), activationEvent);
  }

  public final const func AreaExited() -> Void {
    let activationEvent: ref<NetworkAreaActivationEvent> = new NetworkAreaActivationEvent();
    activationEvent.enable = false;
    this.QueuePSEvent(this.GetID(), this.GetClassName(), activationEvent);
  }

  public final func OnNetworkAreaActivation(evt: ref<NetworkAreaActivationEvent>) -> EntityNotificationType {
    if evt.enable {
      this.Activate();
    } else {
      this.Deactivate();
    };
    return EntityNotificationType.DoNotNotifyEntity;
  }

  private final func Activate() -> Void {
    this.m_isActive = true;
    if this.m_hudActivated {
      this.UpdateNetrunnerHUD();
    };
  }

  private final func Deactivate() -> Void {
    this.m_isActive = false;
    this.HideResourceOnHUD();
  }

  private final func HideResourceOnHUD() -> Void {
    let bbSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.GetGameInstance());
    let bioMonitorHUD: ref<IBlackboard> = bbSystem.Get(GetAllBlackboardDefs().UI_PlayerBioMonitor);
    bioMonitorHUD.SetInt(GetAllBlackboardDefs().UI_PlayerBioMonitor.CurrentNetrunnerCharges, -1);
    GameInstance.GetDebugVisualizerSystem(this.GetGameInstance()).ClearLayer(this.m_visualizerID);
  }

  private final func UpdateNetrunnerHUD() -> Void {
    let bbSystem: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.GetGameInstance());
    let bioMonitorHUD: ref<IBlackboard> = bbSystem.Get(GetAllBlackboardDefs().UI_PlayerBioMonitor);
    bioMonitorHUD.SetInt(GetAllBlackboardDefs().UI_PlayerBioMonitor.CurrentNetrunnerCharges, this.m_currentlyAvailableCharges);
    bioMonitorHUD.SetInt(GetAllBlackboardDefs().UI_PlayerBioMonitor.NetworkChargesCapacity, this.m_maxAvailableCharges);
    bioMonitorHUD.SetName(GetAllBlackboardDefs().UI_PlayerBioMonitor.NetworkName, StringToName(this.m_deviceName));
    GameInstance.GetDebugVisualizerSystem(this.GetGameInstance()).ClearLayer(this.m_visualizerID);
    this.m_visualizerID = GameInstance.GetDebugVisualizerSystem(this.GetGameInstance()).DrawText(new Vector4(20.00, 550.00, 0.00, 0.00), "NETRUNNER CHARGES: " + IntToString(this.m_currentlyAvailableCharges) + " / " + IntToString(this.m_maxAvailableCharges), SColor.Blue());
    this.m_hudActivated = true;
  }
}
