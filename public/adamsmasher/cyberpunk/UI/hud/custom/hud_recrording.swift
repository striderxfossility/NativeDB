
public class hudRecordingController extends inkHUDGameController {

  private let m_root: wref<inkCompoundWidget>;

  private let anim_intro: ref<inkAnimProxy>;

  private let anim_outro: ref<inkAnimProxy>;

  private let anim_loop: ref<inkAnimProxy>;

  private let option_intro: inkAnimOptions;

  private let option_loop: inkAnimOptions;

  private let option_outro: inkAnimOptions;

  private let m_factListener: Uint32;

  protected cb func OnInitialize() -> Bool {
    let ownerObject: ref<GameObject> = this.GetOwnerEntity() as GameObject;
    this.m_factListener = GameInstance.GetQuestsSystem(ownerObject.GetGame()).RegisterListener(n"sq030_braindance_active", this, n"OnFact");
    this.OnFact(GameInstance.GetQuestsSystem(ownerObject.GetGame()).GetFact(n"sq030_braindance_active"));
    this.m_root = this.GetRootWidget() as inkCompoundWidget;
    this.option_intro.fromMarker = n"start_intro";
    this.option_intro.toMarker = n"end_intro_start_loop";
    this.option_loop.fromMarker = n"end_intro_start_loop";
    this.option_loop.toMarker = n"end_loop_start_outro";
    this.option_loop.loopType = inkanimLoopType.Cycle;
    this.option_loop.loopInfinite = true;
    this.option_loop.loopCounter = 99999999u;
    this.option_outro.fromMarker = n"end_loop_start_outro";
    this.option_outro.toMarker = n"end_outro";
    this.m_root.SetVisible(false);
  }

  protected cb func OnUninitialize() -> Bool {
    let ownerObject: ref<GameObject> = this.GetOwnerEntity() as GameObject;
    GameInstance.GetQuestsSystem(ownerObject.GetGame()).UnregisterListener(n"sq030_braindance_active", this.m_factListener);
  }

  public final func OnFact(val: Int32) -> Void {
    if val > 0 {
      this.m_root.SetVisible(true);
      this.anim_loop = this.PlayLibraryAnimation(n"start_recording", this.option_loop);
    } else {
      this.OnOutroEnded();
    };
  }

  public final func OnOutroEnded() -> Void {
    this.anim_loop.Stop();
    this.anim_outro.Stop();
    this.anim_intro.Stop();
    this.m_root.SetVisible(false);
  }
}

public static exec func t1(gi: GameInstance) -> Void {
  AddFact(gi, n"sq030_braindance_active", 1);
}

public static exec func t2(gi: GameInstance) -> Void {
  AddFact(gi, n"sq030_braindance_active", -1);
}
