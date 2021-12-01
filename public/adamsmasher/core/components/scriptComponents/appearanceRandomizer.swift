
public class AppearanceRandomizerComponent extends ScriptableComponent {

  public edit const let m_appearances: array<CName>;

  public edit let m_isEnabled: Bool;

  private final func OnGameAttach() -> Void {
    let appearance: CName;
    if this.m_isEnabled {
      appearance = this.PickAppearance();
      this.ApplyAppearance(appearance);
    };
  }

  private final func ApplyAppearance(appearance: CName) -> Void {
    let evt: ref<entAppearanceEvent> = new entAppearanceEvent();
    evt.appearanceName = appearance;
    this.GetOwner().QueueEvent(evt);
  }

  private final func PickAppearance() -> CName {
    let maxValue: Int32 = ArraySize(this.m_appearances);
    let index: Int32 = RandRange(0, maxValue);
    return this.m_appearances[index];
  }
}
