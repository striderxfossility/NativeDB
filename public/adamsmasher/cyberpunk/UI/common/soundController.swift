
public class InitializationSoundController extends inkLogicController {

  private edit let m_soundControlName: CName;

  private edit let m_initializeSoundName: CName;

  private edit let m_unitializeSoundName: CName;

  protected cb func OnInitialize() -> Bool {
    if NotEquals(this.m_soundControlName, n"") && NotEquals(this.m_initializeSoundName, n"") {
      this.PlaySound(this.m_soundControlName, this.m_initializeSoundName);
    };
  }

  protected cb func OnUninitialize() -> Bool {
    if NotEquals(this.m_soundControlName, n"") && NotEquals(this.m_unitializeSoundName, n"") {
      this.PlaySound(this.m_soundControlName, this.m_unitializeSoundName);
    };
  }
}
