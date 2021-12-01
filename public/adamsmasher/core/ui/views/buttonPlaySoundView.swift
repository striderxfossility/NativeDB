
public class ButtonPlaySoundView extends BaseButtonView {

  @default(ButtonPlaySoundView, Button)
  private edit let m_SoundPrefix: CName;

  @default(ButtonPlaySoundView, OnPress)
  private edit let m_PressSoundName: CName;

  private edit let m_HoverSoundName: CName;

  protected func ButtonStateChanged(oldState: inkEButtonState, newState: inkEButtonState) -> Void {
    if IsNameValid(this.m_SoundPrefix) {
      switch newState {
        case inkEButtonState.Press:
          if IsNameValid(this.m_PressSoundName) {
            this.PlaySound(this.m_SoundPrefix, this.m_PressSoundName);
          };
          break;
        case inkEButtonState.Hover:
          if NotEquals(oldState, inkEButtonState.Press) {
            if IsNameValid(this.m_HoverSoundName) {
              this.PlaySound(this.m_SoundPrefix, this.m_HoverSoundName);
            };
          };
          break;
        default:
      };
    };
  }
}
