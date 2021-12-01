
public class ChestPress extends InteractiveDevice {

  private let m_animFeatureData: ref<AnimFeature_ChestPress>;

  private let m_animFeatureDataName: CName;

  protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
    super.OnRequestComponents(ri);
  }

  protected cb func OnTakeControl(ri: EntityResolveComponentsInterface) -> Bool {
    super.OnTakeControl(ri);
    this.m_controller = EntityResolveComponentsInterface.GetComponent(ri, n"controller") as ChestPressController;
  }

  protected cb func OnGameAttached() -> Bool {
    this.m_animFeatureData = new AnimFeature_ChestPress();
    this.m_animFeatureDataName = n"ChestPressData";
    super.OnGameAttached();
  }

  private const func GetController() -> ref<ScriptableDC> {
    return this.m_controller;
  }

  public const func GetDevicePS() -> ref<ScriptableDeviceComponentPS> {
    return this.GetControllerPersistentState() as ScriptableDeviceComponentPS;
  }

  public const func DeterminGameplayRole() -> EGameplayRole {
    return EGameplayRole.Fall;
  }

  protected cb func OnChestPressWeightHack(evt: ref<ChestPressWeightHack>) -> Bool {
    AddFact(this.GetGame(), (this.GetDevicePS() as ChestPressControllerPS).GetFactOnQHack());
  }

  protected cb func OnE3Hack_QuestPlayAnimationWeightLift(evt: ref<E3Hack_QuestPlayAnimationWeightLift>) -> Bool {
    this.m_animFeatureData.lifting = true;
    this.ApplyAnimFeatureToReplicate(this, this.m_animFeatureDataName, this.m_animFeatureData);
  }

  protected cb func OnE3Hack_QuestPlayAnimationKillNPC(evt: ref<E3Hack_QuestPlayAnimationKillNPC>) -> Bool {
    this.m_animFeatureData.lifting = false;
    this.m_animFeatureData.kill = true;
    this.ApplyAnimFeatureToReplicate(this, this.m_animFeatureDataName, this.m_animFeatureData);
  }
}
