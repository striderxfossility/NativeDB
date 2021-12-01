
public class MaintenancePanel extends InteractiveMasterDevice {

  private let m_animFeature: ref<AnimFeature_SimpleDevice>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"disassemblableComponent", n"DisassemblableComponent", true);
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_disassemblableComponent = EntityResolveComponentsInterface.GetComponent(ri, n"disassemblableComponent") as DisassemblableComponent;
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as MaintenancePanelController;
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  protected func RestoreDeviceState() -> Void {
    this.RestoreDeviceState();
  }

  protected func EnterWorkspot(activator: ref<GameObject>, opt freeCamera: Bool, opt componentName: CName, opt deviceData: CName) -> Void {
    let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(activator.GetGame());
    workspotSystem.PlayInDeviceSimple(this, activator, freeCamera, componentName, n"deviceWorkspot");
  }

  protected cb func OnDisassembleDevice(evt: ref<DisassembleDevice>) -> Bool {
    let playerStateMachineBlackboard: ref<IBlackboard>;
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
    this.EnterWorkspot(playerPuppet, false, n"disassembleWorkspot");
    this.SetGameplayRoleToNone();
    playerStateMachineBlackboard = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice, true);
    this.UpdateDeviceState();
    this.DelayApperanceSwitchEvent(n"Yellow", 1.68);
    this.DelayApperanceSwitchEvent(n"default", 2.98);
    this.DelayApperanceSwitchEvent(n"red", 4.03);
  }

  protected cb func OnDelayApperanceSwitchEvent(evt: ref<panelApperanceSwitchEvent>) -> Bool;

  protected cb func OnWorkspotFinished(componentName: CName) -> Bool {
    let playerPuppet: ref<PlayerPuppet>;
    let playerStateMachineBlackboard: ref<IBlackboard>;
    if Equals(componentName, n"disassembleWorkspot") {
      playerPuppet = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
      playerStateMachineBlackboard = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
      playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice, false);
      this.m_disassemblableComponent.ObtainParts();
      (this.GetDevicePS() as MaintenancePanelControllerPS).RefreshLockOnSlaves();
      this.UpdateAnimState();
    };
  }

  public final const func IsAuthorizationModuleOn() -> Bool {
    return this.GetDevicePS().IsAuthorizationModuleOn();
  }

  private final func UpdateAnimState() -> Void {
    if !IsDefined(this.m_animFeature) {
      this.m_animFeature = new AnimFeature_SimpleDevice();
    };
    this.m_animFeature.isOpen = true;
    this.m_interaction.Toggle(false);
    AnimationControllerComponent.ApplyFeature(this, n"DeviceMaintenancePanel", this.m_animFeature);
  }

  private final func DelayApperanceSwitchEvent(newApperance: CName, time: Float) -> Void {
    let evt: ref<panelApperanceSwitchEvent> = new panelApperanceSwitchEvent();
    evt.newApperance = newApperance;
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, evt, time);
  }
}
