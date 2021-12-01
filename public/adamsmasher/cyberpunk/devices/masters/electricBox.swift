
public class ElectricBox extends InteractiveMasterDevice {

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as ElectricBoxController;
  }

  protected cb func OnGameAttached() -> Bool {
    super.OnGameAttached();
    this.UpdateAnimState();
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.ControlOtherDevice;
  }

  protected cb func OnActionOverride(evt: ref<ActionOverride>) -> Bool {
    let delay: ref<DelayEvent>;
    let playerStateMachineBlackboard: ref<IBlackboard>;
    let playerPuppet: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerControlledGameObject() as PlayerPuppet;
    this.EnterWorkspot(playerPuppet, false, n"disassembleWorkspot");
    this.SetGameplayRoleToNone();
    this.SetQuestFact();
    this.m_interaction.Toggle(false);
    playerStateMachineBlackboard = GameInstance.GetBlackboardSystem(this.GetGame()).GetLocalInstanced(playerPuppet.GetEntityID(), GetAllBlackboardDefs().PlayerStateMachine);
    playerStateMachineBlackboard.SetBool(GetAllBlackboardDefs().PlayerStateMachine.IsInteractingWithDevice, true);
    this.UpdateDeviceState();
    delay = new DelayEvent();
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, delay, 3.40);
  }

  protected cb func OnDelayEvent(evt: ref<DelayEvent>) -> Bool {
    (this.GetDevicePS() as ElectricBoxControllerPS).WorkspotFinished();
  }

  protected final func SetQuestFact() -> Void {
    let properties: ComputerQuickHackData = (this.GetDevicePS() as ElectricBoxControllerPS).GetQuestSetup();
    if IsNameValid(properties.factName) {
      if Equals(properties.operationType, EMathOperationType.Set) {
        SetFactValue(this.GetGame(), properties.factName, properties.factValue);
      } else {
        AddFact(this.GetGame(), properties.factName, properties.factValue);
      };
    };
  }

  protected func EnterWorkspot(activator: ref<GameObject>, opt freeCamera: Bool, opt componentName: CName, opt deviceData: CName) -> Void {
    let workspotSystem: ref<WorkspotGameSystem> = GameInstance.GetWorkspotSystem(activator.GetGame());
    workspotSystem.PlayInDeviceSimple(this, activator, freeCamera, componentName, n"deviceWorkspot");
  }

  private final func UpdateAnimState() -> Void {
    let animFeature: ref<AnimFeature_SimpleDevice> = new AnimFeature_SimpleDevice();
    animFeature.isOpen = (this.GetDevicePS() as ElectricBoxControllerPS).IsOverriden();
    AnimationControllerComponent.ApplyFeature(this, n"DeviceMaintenancePanel", animFeature);
  }
}
