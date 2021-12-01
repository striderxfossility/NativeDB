
public class NetrunnerChairController extends ScriptableDC {

  protected const func GetPS() -> ref<GameComponentPS> {
    return this.GetBasePS();
  }
}

public class NetrunnerChairControllerPS extends ScriptableDeviceComponentPS {

  @default(NetrunnerChairControllerPS, 1.0f)
  protected edit let m_killDelay: Float;

  protected const func CanCreateAnyQuickHackActions() -> Bool {
    return true;
  }

  protected func GetQuickHackActions(out actions: array<ref<DeviceAction>>, context: GetActionsContext) -> Void {
    let currentAction: ref<ScriptableDeviceAction> = this.ActionOverloadDevice();
    currentAction.SetObjectActionID(t"DeviceAction.OverloadClassHack");
    currentAction.SetInactiveWithReason(!this.m_wasQuickHacked && this.IsSomeoneUsingNPCWorkspot(), "LocKey#7011");
    ArrayPush(actions, currentAction);
    this.FinalizeGetQuickHackActions(actions, context);
  }

  protected func ActionOverloadDevice() -> ref<OverloadDevice> {
    let action: ref<OverloadDevice> = this.ActionOverloadDevice();
    action.SetKillDelay(this.m_killDelay);
    return action;
  }

  protected func OnOverloadDevice(evt: ref<OverloadDevice>) -> EntityNotificationType {
    let npc: ref<GameObject> = GameInstance.GetWorkspotSystem(this.GetGameInstance()).GetDeviceUser(PersistentID.ExtractEntityID(this.GetID()));
    if IsDefined(npc) {
      StatusEffectHelper.ApplyStatusEffect(npc, t"WorkspotStatus.Death", this.m_killDelay);
    };
    return this.OnOverloadDevice(evt);
  }
}
