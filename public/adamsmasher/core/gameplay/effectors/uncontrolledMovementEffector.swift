
public class UncontrolledMovementEffector extends Effector {

  public let m_recordID: TweakDBID;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_recordID = record;
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let record: ref<UncontrolledMovementEffector_Record>;
    let startEvent: ref<UncontrolledMovementStartEvent>;
    let ownerPuppet: ref<NPCPuppet> = owner as NPCPuppet;
    if ScriptedPuppet.CanRagdoll(ownerPuppet) {
      startEvent = new UncontrolledMovementStartEvent();
      record = TweakDBInterface.GetUncontrolledMovementEffectorRecord(this.m_recordID);
      startEvent.ragdollNoGroundThreshold = record.RagdollNoGroundThreshold();
      startEvent.ragdollOnCollision = record.RagdollOnCollision();
      startEvent.DebugSetSourceName(record.DebugSourceName());
      owner.QueueEvent(startEvent);
    };
  }
}

public class SetRagdollComponentStateEffector extends Effector {

  public let m_state: Bool;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_state = TweakDBInterface.GetBool(record + t".state", false);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let ownerPuppet: ref<NPCPuppet> = owner as NPCPuppet;
    if IsDefined(ownerPuppet) {
      ownerPuppet.SetDisableRagdoll(!this.m_state);
    };
  }
}
