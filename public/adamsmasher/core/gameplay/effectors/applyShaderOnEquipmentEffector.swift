
public class ApplyShaderOnEquipmentEffector extends Effector {

  private let m_overrideMaterialName: CName;

  private let m_overrideMaterialTag: CName;

  private let m_effectInstance: ref<EffectInstance>;

  private let m_owner: wref<GameObject>;

  private let m_ownerEffect: ref<EffectInstance>;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_overrideMaterialName = TweakDBInterface.GetCName(record + t".overrideMaterialName", n"");
    this.m_overrideMaterialTag = TweakDBInterface.GetCName(record + t".overrideMaterialTag", n"");
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    let evt: ref<SetUpEquipmentOverlayEvent>;
    let i: Int32;
    let item: wref<ItemObject>;
    this.m_owner = owner;
    let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(owner.GetGame());
    let slots: array<TweakDBID> = this.GetAttachmentSlotsForEquipment();
    if IsDefined(this.m_owner as PlayerPuppet) {
      evt = new SetUpEquipmentOverlayEvent();
      evt.meshOverlayEffectName = this.m_overrideMaterialName;
      evt.meshOverlayEffectTag = this.m_overrideMaterialTag;
      evt.meshOverlaySlots = slots;
      this.m_owner.QueueEvent(evt);
    };
    i = 0;
    while i < ArraySize(slots) {
      item = ts.GetItemInSlot(owner, slots[i]);
      if IsDefined(item) {
        this.m_effectInstance = GameInstance.GetGameEffectSystem(this.m_owner.GetGame()).CreateEffectStatic(this.m_overrideMaterialName, this.m_overrideMaterialTag, this.m_owner);
        if IsDefined(this.m_effectInstance) && IsNameValid(this.m_overrideMaterialName) {
          EffectData.SetBool(this.m_effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.enable, true);
          EffectData.SetBool(this.m_effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.clearMaterialOverlayOnDetach, true);
          EffectData.SetEntity(this.m_effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.entity, item);
          this.m_effectInstance.Run();
        };
      };
      i += 1;
    };
    this.m_effectInstance = GameInstance.GetGameEffectSystem(this.m_owner.GetGame()).CreateEffectStatic(this.m_overrideMaterialName, this.m_overrideMaterialTag, this.m_owner);
    if IsDefined(this.m_effectInstance) && IsNameValid(this.m_overrideMaterialName) {
      EffectData.SetBool(this.m_effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.enable, true);
      EffectData.SetBool(this.m_effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.clearMaterialOverlayOnDetach, true);
      EffectData.SetEntity(this.m_effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.entity, this.m_owner);
      this.m_effectInstance.Run();
    };
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    let evt: ref<SetUpEquipmentOverlayEvent>;
    let i: Int32;
    let item: wref<ItemObject>;
    let slots: array<TweakDBID>;
    let ts: ref<TransactionSystem>;
    if IsDefined(this.m_owner as PlayerPuppet) {
      evt = new SetUpEquipmentOverlayEvent();
      evt.meshOverlayEffectName = n"";
      evt.meshOverlayEffectTag = n"";
      evt.meshOverlaySlots = slots;
      this.m_owner.QueueEvent(evt);
    };
    ts = GameInstance.GetTransactionSystem(game);
    slots = this.GetAttachmentSlotsForEquipment();
    i = 0;
    while i < ArraySize(slots) {
      item = ts.GetItemInSlot(this.m_owner, slots[i]);
      if IsDefined(item) {
        this.m_effectInstance = GameInstance.GetGameEffectSystem(game).CreateEffectStatic(this.m_overrideMaterialName, this.m_overrideMaterialTag, this.m_owner);
        if IsDefined(this.m_effectInstance) && IsNameValid(this.m_overrideMaterialName) {
          EffectData.SetBool(this.m_effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.enable, false);
          EffectData.SetEntity(this.m_effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.entity, item);
          this.m_effectInstance.Run();
        };
      };
      i += 1;
    };
    this.m_effectInstance = GameInstance.GetGameEffectSystem(game).CreateEffectStatic(this.m_overrideMaterialName, this.m_overrideMaterialTag, this.m_owner);
    if IsDefined(this.m_effectInstance) && IsNameValid(this.m_overrideMaterialName) {
      EffectData.SetBool(this.m_effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.enable, false);
      EffectData.SetEntity(this.m_effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.entity, this.m_owner);
      this.m_effectInstance.Run();
    };
  }

  private final const func GetAttachmentSlotsForEquipment() -> array<TweakDBID> {
    let slots: array<TweakDBID>;
    ArrayPush(slots, t"AttachmentSlots.Underwear");
    ArrayPush(slots, t"AttachmentSlots.Chest");
    ArrayPush(slots, t"AttachmentSlots.Torso");
    ArrayPush(slots, t"AttachmentSlots.Head");
    ArrayPush(slots, t"AttachmentSlots.Face");
    ArrayPush(slots, t"AttachmentSlots.Legs");
    ArrayPush(slots, t"AttachmentSlots.Feet");
    ArrayPush(slots, t"AttachmentSlots.RightArm");
    return slots;
  }
}
