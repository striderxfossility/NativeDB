
public class AnimFeature_StatusEffect extends AnimFeature {

  public edit let state: Int32;

  @default(AnimFeature_StatusEffect, -1.f)
  public edit let duration: Float;

  @default(AnimFeature_StatusEffect, 1)
  public edit let variation: Int32;

  public edit let direction: Int32;

  @default(AnimFeature_StatusEffect, -1)
  public edit let impactDirection: Int32;

  public edit let knockdown: Bool;

  public edit let stunned: Bool;

  @default(AnimFeature_StatusEffect, false)
  public edit let playImpact: Bool;

  public final func Clear() -> Void {
    this.state = 0;
    this.impactDirection = -1;
    this.knockdown = false;
    this.stunned = false;
    this.playImpact = false;
  }
}
