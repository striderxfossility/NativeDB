
public class InvestigationReactionFilter extends EffectObjectSingleFilter_Scripted {

  public final func Process(ctx: EffectScriptContext, filterCtx: EffectSingleFilterScriptContext) -> Bool {
    let source: ref<GameObject>;
    let stim: ref<StimuliEvent>;
    let stimType: gamedataStimType;
    let stimVariant: Variant;
    let returnValue: Bool = true;
    EffectData.GetVariant(EffectScriptContext.GetSharedData(ctx), GetAllBlackboardDefs().EffectSharedData.stimuliEvent, stimVariant);
    stim = FromVariant(stimVariant);
    if IsDefined(stim) {
      stimType = stim.GetStimType();
      if Equals(stimType, gamedataStimType.Distract) {
        source = EffectScriptContext.GetSource(ctx) as GameObject;
        if source != null {
          returnValue = source.CanBeInvestigated();
        };
      };
    };
    return returnValue;
  }
}
