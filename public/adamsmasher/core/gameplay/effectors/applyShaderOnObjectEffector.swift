
public class ApplyShaderOnObjectEffector extends Effector {

  private let m_applicationTargetString: String;

  private let m_applicationTarget: wref<GameObject>;

  private let m_effects: array<ref<EffectInstance>>;

  private let m_overrideMaterialName: CName;

  private let m_overrideMaterialTag: CName;

  private let m_overrideMaterialClearOnDetach: Bool;

  private let m_effectInstance: ref<EffectInstance>;

  private let m_owner: wref<GameObject>;

  private let m_ownerEffect: ref<EffectInstance>;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_applicationTargetString = TweakDBInterface.GetString(record + t".applicationTarget", "");
    this.m_overrideMaterialName = TweakDBInterface.GetCName(record + t".overrideMaterialName", n"");
    this.m_overrideMaterialTag = TweakDBInterface.GetCName(record + t".overrideMaterialTag", n"");
    this.m_overrideMaterialClearOnDetach = TweakDBInterface.GetBool(record + t".overrideMaterialClearOnDetach", false);
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.m_owner = owner;
    this.GetApplicationTarget(this.m_owner, this.m_applicationTargetString, this.m_applicationTarget);
    this.m_effectInstance = GameInstance.GetGameEffectSystem(this.m_owner.GetGame()).CreateEffectStatic(this.m_overrideMaterialName, this.m_overrideMaterialTag, this.m_owner);
    if IsDefined(this.m_effectInstance) && IsNameValid(this.m_overrideMaterialName) && IsDefined(this.m_applicationTarget) {
      EffectData.SetBool(this.m_effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.enable, true);
      EffectData.SetBool(this.m_effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.clearMaterialOverlayOnDetach, this.m_overrideMaterialClearOnDetach);
      EffectData.SetEntity(this.m_effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.entity, this.m_applicationTarget);
      this.m_effectInstance.Run();
    };
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    this.m_effectInstance = GameInstance.GetGameEffectSystem(this.m_owner.GetGame()).CreateEffectStatic(this.m_overrideMaterialName, this.m_overrideMaterialTag, this.m_owner);
    if IsDefined(this.m_effectInstance) && IsNameValid(this.m_overrideMaterialName) && IsDefined(this.m_applicationTarget) {
      EffectData.SetBool(this.m_effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.enable, false);
      EffectData.SetEntity(this.m_effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.entity, this.m_applicationTarget);
      this.m_effectInstance.Run();
    };
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    this.m_effectInstance = GameInstance.GetGameEffectSystem(game).CreateEffectStatic(this.m_overrideMaterialName, this.m_overrideMaterialTag, this.m_owner);
    if IsDefined(this.m_effectInstance) && IsNameValid(this.m_overrideMaterialName) {
      EffectData.SetBool(this.m_effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.enable, false);
      EffectData.SetEntity(this.m_effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.entity, this.m_applicationTarget);
      this.m_effectInstance.Run();
    };
  }
}
