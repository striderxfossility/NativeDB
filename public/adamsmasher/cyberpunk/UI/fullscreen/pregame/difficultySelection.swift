
public class DifficultySelectionMenu extends BaseCharacterCreationController {

  public edit let m_difficultyTitle: inkTextRef;

  public edit let m_difficultyIcon: inkImageRef;

  public edit let m_difficulty0: inkWidgetRef;

  public edit let m_difficulty1: inkWidgetRef;

  public edit let m_difficulty2: inkWidgetRef;

  public edit let m_difficulty3: inkWidgetRef;

  private let m_animationProxy: ref<inkAnimProxy>;

  @default(DifficultySelectionMenu, base\gameplay\gui\fullscreen\main_menu\difficulty_level.inkatlas)
  private const let c_atlas1: ResRef;

  @default(DifficultySelectionMenu, base\gameplay\gui\fullscreen\main_menu\difficulty_level1.inkatlas)
  private const let c_atlas2: ResRef;

  private let translationAnimationCtrl: wref<inkTextReplaceController>;

  private let localizedText: String;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    inkWidgetRef.RegisterToCallback(this.m_difficulty0, n"OnHoverOver", this, n"OnHoverOverDifficulty0");
    inkWidgetRef.RegisterToCallback(this.m_difficulty1, n"OnHoverOver", this, n"OnHoverOverDifficulty1");
    inkWidgetRef.RegisterToCallback(this.m_difficulty2, n"OnHoverOver", this, n"OnHoverOverDifficulty2");
    inkWidgetRef.RegisterToCallback(this.m_difficulty3, n"OnHoverOver", this, n"OnHoverOverDifficulty3");
    this.GetTelemetrySystem().LogInitialChoiceSetStatege(telemetryInitalChoiceStage.Difficulty);
    this.OnIntro();
  }

  protected cb func OnUninitialize() -> Bool {
    super.OnUninitialize();
  }

  protected cb func OnHoverOverDifficulty0(e: ref<inkPointerEvent>) -> Bool {
    inkImageRef.SetAtlasResource(this.m_difficultyIcon, this.c_atlas1);
    inkImageRef.SetTexturePart(this.m_difficultyIcon, n"story");
    this.localizedText = GetLocalizedText("LocKey#54124");
    this.translationAnimationCtrl.SetBaseText("...");
    this.translationAnimationCtrl = inkWidgetRef.GetController(this.m_difficultyTitle) as inkTextReplaceController;
    this.translationAnimationCtrl.SetTargetText(this.localizedText);
    this.translationAnimationCtrl.PlaySetAnimation();
  }

  protected cb func OnHoverOverDifficulty1(e: ref<inkPointerEvent>) -> Bool {
    inkImageRef.SetAtlasResource(this.m_difficultyIcon, this.c_atlas1);
    inkImageRef.SetTexturePart(this.m_difficultyIcon, n"fight");
    this.localizedText = GetLocalizedText("LocKey#54125");
    this.translationAnimationCtrl.SetBaseText("...");
    this.translationAnimationCtrl = inkWidgetRef.GetController(this.m_difficultyTitle) as inkTextReplaceController;
    this.translationAnimationCtrl.SetTargetText(this.localizedText);
    this.translationAnimationCtrl.PlaySetAnimation();
  }

  protected cb func OnHoverOverDifficulty2(e: ref<inkPointerEvent>) -> Bool {
    inkImageRef.SetAtlasResource(this.m_difficultyIcon, this.c_atlas2);
    inkImageRef.SetTexturePart(this.m_difficultyIcon, n"hard");
    this.localizedText = GetLocalizedText("LocKey#54126");
    this.translationAnimationCtrl.SetBaseText("...");
    this.translationAnimationCtrl = inkWidgetRef.GetController(this.m_difficultyTitle) as inkTextReplaceController;
    this.translationAnimationCtrl.SetTargetText(this.localizedText);
    this.translationAnimationCtrl.PlaySetAnimation();
  }

  protected cb func OnHoverOverDifficulty3(e: ref<inkPointerEvent>) -> Bool {
    inkImageRef.SetAtlasResource(this.m_difficultyIcon, this.c_atlas2);
    inkImageRef.SetTexturePart(this.m_difficultyIcon, n"deathmarch");
    this.localizedText = GetLocalizedText("LocKey#54127");
    this.translationAnimationCtrl.SetBaseText("...");
    this.translationAnimationCtrl = inkWidgetRef.GetController(this.m_difficultyTitle) as inkTextReplaceController;
    this.translationAnimationCtrl.SetTargetText(this.localizedText);
    this.translationAnimationCtrl.PlaySetAnimation();
  }

  protected cb func OnButtonRelease(evt: ref<inkPointerEvent>) -> Bool {
    if !evt.IsHandled() {
      if evt.IsAction(n"back") {
        this.PlaySound(n"Button", n"OnPress");
        evt.Handle();
        this.PriorMenu();
      } else {
        return false;
      };
      evt.Handle();
    };
  }

  protected cb func OnRelease(e: ref<inkPointerEvent>) -> Bool {
    let target: wref<inkWidget> = e.GetTarget();
    if e.IsAction(n"click") {
      this.PlaySound(n"Button", n"OnPress");
      switch target {
        case inkWidgetRef.Get(this.m_difficulty0):
          GameInstance.GetStatsDataSystem(this.GetPlayerControlledObject().GetGame()).SetDifficulty(gameDifficulty.Story);
          this.GetTelemetrySystem().LogInitialChoiceDifficultySelected(gameDifficulty.Story);
          this.NextMenu();
          break;
        case inkWidgetRef.Get(this.m_difficulty1):
          GameInstance.GetStatsDataSystem(this.GetPlayerControlledObject().GetGame()).SetDifficulty(gameDifficulty.Easy);
          this.GetTelemetrySystem().LogInitialChoiceDifficultySelected(gameDifficulty.Easy);
          this.NextMenu();
          break;
        case inkWidgetRef.Get(this.m_difficulty2):
          GameInstance.GetStatsDataSystem(this.GetPlayerControlledObject().GetGame()).SetDifficulty(gameDifficulty.Hard);
          this.GetTelemetrySystem().LogInitialChoiceDifficultySelected(gameDifficulty.Hard);
          this.NextMenu();
          break;
        case inkWidgetRef.Get(this.m_difficulty3):
          GameInstance.GetStatsDataSystem(this.GetPlayerControlledObject().GetGame()).SetDifficulty(gameDifficulty.VeryHard);
          this.GetTelemetrySystem().LogInitialChoiceDifficultySelected(gameDifficulty.VeryHard);
          this.NextMenu();
      };
    };
  }

  protected func PriorMenu() -> Void {
    this.GetTelemetrySystem().LogInitialChoiceSetStatege(IntEnum(0l));
    this.PriorMenu();
  }

  protected func NextMenu() -> Void {
    this.OnOutro();
  }

  private final func OnIntro() -> Void {
    this.PlayLibraryAnimation(n"intro");
    this.PlayAnim(n"intro_sound", n"OnIntroComplete");
  }

  private final func OnOutro() -> Void {
    this.PlayAnim(n"outro", n"OnOutroComplete");
  }

  protected cb func OnOutroComplete(anim: ref<inkAnimProxy>) -> Bool {
    this.NextMenu();
  }

  protected cb func OnIntroComplete(anim: ref<inkAnimProxy>) -> Bool {
    this.PlaySound(n"CharacterCreationConfirmationAnimation", n"OnOpen");
  }

  public final func PlayAnim(animName: CName, opt callBack: CName) -> Void {
    if IsDefined(this.m_animationProxy) && this.m_animationProxy.IsPlaying() {
      this.m_animationProxy.Stop();
    };
    this.m_animationProxy = this.PlayLibraryAnimation(animName);
    if NotEquals(callBack, n"") {
      this.m_animationProxy.RegisterToCallback(inkanimEventType.OnFinish, this, callBack);
    };
  }
}
