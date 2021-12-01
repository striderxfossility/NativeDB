
public class InkAnimHelper extends IScriptable {

  public final static func GetDef_Transparency(startAlpha: Float, endAlpha: Float, duration: Float, delay: Float, type: inkanimInterpolationType, mode: inkanimInterpolationMode) -> ref<inkAnimDef> {
    let definition: ref<inkAnimDef> = new inkAnimDef();
    let alphaInterpol: ref<inkAnimTransparency> = new inkAnimTransparency();
    alphaInterpol.SetStartTransparency(startAlpha);
    alphaInterpol.SetEndTransparency(endAlpha);
    alphaInterpol.SetDuration(duration);
    alphaInterpol.SetStartDelay(delay);
    alphaInterpol.SetType(type);
    alphaInterpol.SetMode(mode);
    definition.AddInterpolator(alphaInterpol);
    return definition;
  }

  public final static func GetDef_Blink(startAlpha: Float, endAlpha: Float, duration: Float, delay: Float, type: inkanimInterpolationType, mode: inkanimInterpolationMode) -> ref<inkAnimDef> {
    let alphaBlinkOutInterpol: ref<inkAnimTransparency>;
    let halfDuration: Float = duration / 2.00;
    let definition: ref<inkAnimDef> = new inkAnimDef();
    let alphaBlinkInInterpol: ref<inkAnimTransparency> = new inkAnimTransparency();
    alphaBlinkInInterpol.SetStartTransparency(startAlpha);
    alphaBlinkInInterpol.SetEndTransparency(endAlpha);
    alphaBlinkInInterpol.SetDuration(halfDuration);
    alphaBlinkInInterpol.SetStartDelay(delay);
    alphaBlinkInInterpol.SetType(type);
    alphaBlinkInInterpol.SetMode(mode);
    alphaBlinkOutInterpol = new inkAnimTransparency();
    alphaBlinkOutInterpol.SetStartTransparency(endAlpha);
    alphaBlinkOutInterpol.SetEndTransparency(startAlpha);
    alphaBlinkOutInterpol.SetStartDelay(halfDuration);
    alphaBlinkOutInterpol.SetDuration(delay + halfDuration);
    alphaBlinkOutInterpol.SetType(type);
    alphaBlinkOutInterpol.SetMode(mode);
    definition.AddInterpolator(alphaBlinkInInterpol);
    definition.AddInterpolator(alphaBlinkOutInterpol);
    return definition;
  }
}
