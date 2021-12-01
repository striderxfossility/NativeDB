
public class DisassemblableComponent extends ScriptableComponent {

  @default(DisassemblableComponent, false)
  private let disassembled: Bool;

  private let disassembleTargetRequesters: array<wref<GameObject>>;

  protected final func OnGameAttach() -> Void;

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool;

  protected final func OnGameDetach() -> Void;

  protected final func OnUpdate(deltaTime: Float) -> Void;

  public final const func ObtainParts() -> Void {
    let trans: ref<TransactionSystem>;
    let player: ref<PlayerPuppet> = this.GetPlayerSystem().GetLocalPlayerMainGameObject() as PlayerPuppet;
    RPGManager.GiveScavengeReward(player.GetGame(), t"RPGActionRewards.ExtractParts", this.GetOwner().GetEntityID());
    trans = this.GetTransactionSystem();
    GameInstance.GetActivityLogSystem(player.GetGame()).AddLog("Device disassembled. You now have " + ToString(trans.GetItemQuantity(player, ItemID.CreateQuery(t"Items.parts"))) + " parts.");
  }

  protected cb func OnTargetRequested(evt: ref<DisassembleTargetRequest>) -> Bool {
    let scavengeTargetEvent: ref<ScavengeTargetConfirmEvent>;
    if !this.disassembled {
      scavengeTargetEvent = new ScavengeTargetConfirmEvent();
      scavengeTargetEvent.target = this.GetOwner();
      evt.requester.QueueEvent(scavengeTargetEvent);
      if !ArrayContains(this.disassembleTargetRequesters, evt.requester) {
        ArrayPush(this.disassembleTargetRequesters, evt.requester);
      };
    };
  }

  protected cb func OnDisassembled(evt: ref<DisassembleEvent>) -> Bool {
    let i: Int32;
    let targetScavengedEvent: ref<TargetScavengedEvent>;
    if !this.disassembled {
      this.ObtainParts();
      this.disassembled = true;
      i = ArraySize(this.disassembleTargetRequesters) - 1;
      while i >= 0 {
        targetScavengedEvent = new TargetScavengedEvent();
        targetScavengedEvent.target = this.GetOwner();
        this.disassembleTargetRequesters[i].QueueEvent(targetScavengedEvent);
        ArrayErase(this.disassembleTargetRequesters, i);
        i -= 1;
      };
    };
  }
}
