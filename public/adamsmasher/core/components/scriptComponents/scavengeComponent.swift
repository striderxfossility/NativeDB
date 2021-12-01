
public class ScavengeComponent extends ScriptableComponent {

  public let m_scavengeTargets: array<wref<GameObject>>;

  public final func OnGameAttach() -> Void;

  protected cb func OnSenseVisibilityEvent(evt: ref<SenseVisibilityEvent>) -> Bool {
    let disassembleTargetRequest: ref<DisassembleTargetRequest>;
    if Equals(evt.description, n"Disassemblable") && !ArrayContains(this.m_scavengeTargets, evt.target) {
      disassembleTargetRequest = new DisassembleTargetRequest();
      disassembleTargetRequest.requester = this.GetOwner();
      evt.target.QueueEvent(disassembleTargetRequest);
    };
  }

  protected cb func OnScavengeTargetReceived(evt: ref<ScavengeTargetConfirmEvent>) -> Bool {
    ArrayPush(this.m_scavengeTargets, evt.target);
  }

  protected cb func OnTargetScavenged(evt: ref<TargetScavengedEvent>) -> Bool {
    if ArrayContains(this.m_scavengeTargets, evt.target) {
      ArrayRemove(this.m_scavengeTargets, evt.target);
    };
  }

  public final const func GetScavengeTargets() -> array<wref<GameObject>> {
    return this.m_scavengeTargets;
  }
}
