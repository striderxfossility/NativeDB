
public class AIPhaseStateEventHandlerComponent extends AIRelatedComponents {

  public edit let m_phaseStateValue: ENPCPhaseState;

  protected cb func OnWeakspotDestroyEvent(evt: ref<WeakspotOnDestroyEvent>) -> Bool {
    (this.GetOwner() as gamePuppet).GetBlackboard().SetInt(GetAllBlackboardDefs().PuppetState.PhaseState, EnumInt(this.m_phaseStateValue));
  }
}
