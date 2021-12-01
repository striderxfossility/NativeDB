
public class PlayBreathingAnimationEffector extends Effector {

  public let m_animFeature: ref<AnimFeature_CameraBreathing>;

  public let m_animFeatureName: CName;

  public let m_owner: wref<GameObject>;

  protected func Initialize(record: TweakDBID, game: GameInstance, parentRecord: TweakDBID) -> Void {
    let blendInDuration: Float;
    let blendOutDuration: Float;
    this.m_animFeatureName = TweakDBInterface.GetCName(record + t".animFeatureName", n"");
    if !IsNameValid(this.m_animFeatureName) {
      return;
    };
    this.m_animFeature = new AnimFeature_CameraBreathing();
    this.m_animFeature.amplitudeWeight = TweakDBInterface.GetFloat(record + t".amplitudeWeight", 0.00);
    blendInDuration = TweakDBInterface.GetFloat(record + t".blendInDuration", 0.00);
    blendOutDuration = TweakDBInterface.GetFloat(record + t".blendOutDuration", 0.00);
    this.m_animFeature.dampIncreaseSpeed = blendInDuration > 0.00 ? this.m_animFeature.amplitudeWeight / blendInDuration : 9999.00;
    this.m_animFeature.dampDecreaseSpeed = blendOutDuration > 0.00 ? this.m_animFeature.amplitudeWeight / blendOutDuration : 9999.00;
  }

  protected func ActionOn(owner: ref<GameObject>) -> Void {
    this.m_owner = owner;
    if IsDefined(this.m_animFeature) && IsDefined(this.m_owner) {
      AnimationControllerComponent.ApplyFeature(this.m_owner, this.m_animFeatureName, this.m_animFeature);
    };
  }

  protected func ActionOff(owner: ref<GameObject>) -> Void {
    if IsDefined(this.m_animFeature) && IsDefined(this.m_owner) {
      this.m_animFeature.amplitudeWeight = 0.00;
      AnimationControllerComponent.ApplyFeature(this.m_owner, this.m_animFeatureName, this.m_animFeature);
    };
  }

  protected func Uninitialize(game: GameInstance) -> Void {
    if IsDefined(this.m_animFeature) && IsDefined(this.m_owner) {
      this.m_animFeature.amplitudeWeight = 0.00;
      AnimationControllerComponent.ApplyFeature(this.m_owner, this.m_animFeatureName, this.m_animFeature);
    };
  }
}
