
public class FollowSlotsComponent extends ScriptableComponent {

  private inline const let m_followSlots: array<ref<FollowSlot>>;

  public final func OnGameAttach() -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_followSlots) {
      this.m_followSlots[i].id = i;
      i += 1;
    };
  }

  private final func GetClosestAvailableSlot(requester: wref<GameObject>) -> ref<FollowSlot> {
    let availableSlots: array<Int32> = this.GetAllAvailableSlots();
    let closestSlot: ref<FollowSlot> = this.m_followSlots[availableSlots[0]];
    let requesterPosition: Vector4 = requester.GetWorldPosition();
    let i: Int32 = 0;
    while i < ArraySize(availableSlots) {
      if Vector4.Distance(requesterPosition, this.GetCurrentWorldPositionOfSlot(this.m_followSlots[availableSlots[i]])) < Vector4.Distance(requesterPosition, this.GetCurrentWorldPositionOfSlot(closestSlot)) {
        closestSlot = this.m_followSlots[availableSlots[i]];
      };
      i += 1;
    };
    return closestSlot;
  }

  private final func GetAllAvailableSlots() -> array<Int32> {
    let availableSlots: array<Int32>;
    let i: Int32 = 0;
    while i < ArraySize(this.m_followSlots) {
      if this.m_followSlots[i].isAvailable && this.m_followSlots[i].isEnabled {
        ArrayPush(availableSlots, i);
      };
      i += 1;
    };
    return availableSlots;
  }

  private final func GetCurrentWorldPositionOfSlot(slot: ref<FollowSlot>) -> Vector4 {
    let slotWorldOffsetFromVehicle: Vector4 = Vector4.RotByAngleXY(Transform.GetPosition(slot.slotTransform), -1.00 * Vector4.Heading(this.GetOwner().GetWorldForward()));
    let currentWorldPosition: Vector4 = this.GetOwner().GetWorldPosition() + slotWorldOffsetFromVehicle;
    return currentWorldPosition;
  }

  protected cb func OnReceiveSlotRequest(evt: ref<RequestSlotEvent>) -> Bool {
    let availableSlot: ref<FollowSlot>;
    let allAvailableSlots: array<Int32> = this.GetAllAvailableSlots();
    if ArraySize(allAvailableSlots) > 0 {
      availableSlot = this.GetClosestAvailableSlot(evt.requester);
      availableSlot.isAvailable = false;
      evt.blackboard.SetInt(GetAllBlackboardDefs().AIFollowSlot.slotID, availableSlot.id);
      evt.blackboard.SetVariant(GetAllBlackboardDefs().AIFollowSlot.slotTransform, ToVariant(availableSlot.slotTransform));
    };
  }

  protected cb func OnSlotReleased(evt: ref<ReleaseSlotEvent>) -> Bool {
    this.m_followSlots[evt.slotID].isAvailable = true;
  }
}
