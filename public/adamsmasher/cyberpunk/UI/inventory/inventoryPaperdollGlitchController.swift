
public class PaperdollGlitchController extends inkLogicController {

  protected edit let m_PaperdollGlichRoot: inkWidgetRef;

  private edit let m_GlitchAnimationName: CName;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.Get(this.m_PaperdollGlichRoot).SetEffectEnabled(inkEffectType.Glitch, n"Glitch_0", true);
    inkWidgetRef.Get(this.m_PaperdollGlichRoot).SetEffectEnabled(inkEffectType.BoxBlur, n"BoxBlur_0", true);
    this.PlayLibraryAnimation(this.m_GlitchAnimationName);
    if IsNameValid(this.m_GlitchAnimationName) {
      this.PlayLibraryAnimation(this.m_GlitchAnimationName);
    };
  }
}
