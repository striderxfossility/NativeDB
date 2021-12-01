
public class AntiRadar extends WeaponObject {

  private let m_colliderComponent: ref<IComponent>;

  private edit let m_gameEffectRef: EffectRef;

  private let gameEffectInstance: ref<EffectInstance>;

  private let jammedSensorsArray: array<wref<SensorDevice>>;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    EntityRequestComponentsInterface.RequestComponent(ri, n"jammer", n"entColliderComponent", false);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    this.m_colliderComponent = EntityResolveComponentsInterface.GetComponent(ri, n"jammer");
  }

  protected cb func OnGameAttached() -> Bool;

  protected cb func OnCollision(eventData: ref<gameprojectileHitEvent>) -> Bool;

  protected cb func OnHit(evt: ref<gameHitEvent>) -> Bool;

  protected cb func OnChargeStartedEvent(evt: ref<ChargeStartedEvent>) -> Bool {
    let player: ref<PlayerPuppet> = GetPlayer(this.GetGame());
    this.gameEffectInstance = GameInstance.GetGameEffectSystem(this.GetGame()).CreateEffect(this.m_gameEffectRef, player, this);
    this.gameEffectInstance.AttachToEntity(player, GetAllBlackboardDefs().EffectSharedData.position);
    this.gameEffectInstance.Run();
    this.ChangeAppearance(n"green");
  }

  protected cb func OnChargeEndedEvent(evt: ref<ChargeEndedEvent>) -> Bool {
    let i: Int32;
    let jammedEvt: ref<SetJammedEvent> = new SetJammedEvent();
    if IsDefined(this.gameEffectInstance) {
      this.gameEffectInstance.Terminate();
      if ArraySize(this.jammedSensorsArray) != 0 {
        i = 0;
        while i < ArraySize(this.jammedSensorsArray) {
          jammedEvt.newJammedState = false;
          jammedEvt.instigator = this;
          this.jammedSensorsArray[i].QueueEvent(jammedEvt);
          i += 1;
        };
        ArrayClear(this.jammedSensorsArray);
      };
    };
    this.ChangeAppearance(n"default");
  }

  protected cb func OnSensorJammed(evt: ref<SensorJammed>) -> Bool {
    let jammedEvt: ref<SetJammedEvent> = new SetJammedEvent();
    if !ArrayContains(this.jammedSensorsArray, evt.sensor) {
      ArrayPush(this.jammedSensorsArray, evt.sensor);
      jammedEvt.newJammedState = true;
      jammedEvt.instigator = this;
      evt.sensor.QueueEvent(jammedEvt);
    };
  }

  protected final func ChangeAppearance(newAppearance: CName) -> Void {
    let evt: ref<entAppearanceEvent> = new entAppearanceEvent();
    evt.appearanceName = newAppearance;
    this.QueueEvent(evt);
  }
}
