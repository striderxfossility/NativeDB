
public class ToggleMaterialOverlayEffector extends Effector {

  private let m_effectPath: String;

  private let m_effectTag: CName;

  private let m_effectInstance: ref<EffectInstance>;

  private let m_owner: wref<GameObject>;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    this.m_effectPath = TweakDBInterface.GetString(record + t".effectPath", "");
    this.m_effectTag = TweakDBInterface.GetCName(record + t".effectTag", n"");
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.m_owner = owner;
    if !IsDefined(this.m_effectInstance) {
      this.m_effectInstance = GameInstance.GetGameEffectSystem(owner.GetGame()).CreateEffectStatic(StringToName(this.m_effectPath), this.m_effectTag, this.m_owner);
      EffectData.SetEntity(this.m_effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.entity, this.m_owner);
      EffectData.SetBool(this.m_effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.renderMaterialOverride, false);
    };
    EffectData.SetBool(this.m_effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.enable, true);
    this.m_effectInstance.Run();
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    if IsDefined(this.m_effectInstance) {
      EffectData.SetBool(this.m_effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.enable, false);
      this.m_effectInstance.Run();
    };
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    if IsDefined(this.m_effectInstance) {
      EffectData.SetBool(this.m_effectInstance.GetSharedData(), GetAllBlackboardDefs().EffectSharedData.enable, false);
      this.m_effectInstance.Run();
    };
  }
}
