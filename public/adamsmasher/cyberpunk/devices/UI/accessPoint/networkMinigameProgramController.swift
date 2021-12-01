
public class NetworkMinigameProgramController extends inkLogicController {

  protected edit let m_text: inkTextRef;

  protected edit const let m_commandElementSlotsContainer: array<inkWidgetRef>;

  protected edit let m_elementLibraryName: CName;

  protected edit let m_completedMarker: inkWidgetRef;

  protected edit let m_imageRef: inkImageRef;

  protected let m_slotList: array<array<wref<NetworkMinigameElementController>>>;

  protected let m_data: ProgramData;

  private let m_animProxy: ref<inkAnimProxy>;

  protected cb func OnInitialize() -> Bool {
    inkWidgetRef.SetVisible(this.m_completedMarker, false);
    inkTextRef.SetText(this.m_text, "");
  }

  public final func Spawn(data: ProgramData) -> Void {
    let i: Int32;
    let j: Int32;
    let slot: wref<inkWidget>;
    let slotLogic: wref<NetworkMinigameElementController>;
    let slotLogicContent: array<wref<NetworkMinigameElementController>>;
    this.m_data = data;
    inkTextRef.SetText(this.m_text, data.id);
    this.RefreshImage();
    j = 0;
    while j < ArraySize(data.commandLists) {
      ArrayClear(slotLogicContent);
      i = 0;
      while i < ArraySize(data.commandLists[j]) {
        slot = this.SpawnFromLocal(inkWidgetRef.Get(this.m_commandElementSlotsContainer[j]), this.m_elementLibraryName);
        slotLogic = slot.GetController() as NetworkMinigameElementController;
        slotLogic.SetContent(data.commandLists[j][i]);
        ArrayPush(slotLogicContent, slotLogic);
        i += 1;
      };
      ArrayPush(this.m_slotList, slotLogicContent);
      j += 1;
    };
  }

  public final func UpdatePartialCompletionState(progress: ProgramProgressData) -> Void {
    if progress.isComplete {
      if !this.m_data.wasCompleted {
        this.ShowCompleted(progress.revealLocalizedName);
      };
      return;
    };
    this.SetHighlightedUpUntil(progress.completionProgress);
  }

  private final func SetHighlightedUpUntil(lastHighlighted: array<Int32>) -> Void {
    let i: Int32;
    let j: Int32 = 0;
    while j < ArraySize(this.m_slotList) {
      i = 0;
      while i < ArraySize(this.m_slotList[j]) {
        this.m_slotList[j][i].SetHighlightStatus(i < lastHighlighted[j]);
        i += 1;
      };
      j += 1;
    };
  }

  public func ShowCompleted(revealLocalizedName: Bool) -> Void {
    inkWidgetRef.SetVisible(this.m_completedMarker, true);
    this.m_data.wasCompleted = true;
    if revealLocalizedName {
      inkTextRef.SetText(this.m_text, this.m_data.localizationKey);
    };
    this.PlayAnim(n"program_unlocked");
  }

  public final func GetData() -> ProgramData {
    return this.m_data;
  }

  public final func RefreshImage() -> Void {
    switch this.m_data.id {
      case "Encrypted Data Package":
        inkImageRef.SetTexturePart(this.m_imageRef, n"program_ico_01");
        break;
      case "Basic Access":
        inkImageRef.SetTexturePart(this.m_imageRef, n"program_ico_01");
        break;
      case "Network Cache":
        inkImageRef.SetTexturePart(this.m_imageRef, n"program_ico_02");
        break;
      case "Camera Malfunction":
        inkImageRef.SetTexturePart(this.m_imageRef, n"program_ico_03");
        break;
      case "Officer tracing":
        inkImageRef.SetTexturePart(this.m_imageRef, n"program_ico_04");
    };
  }

  public final func PlayAnim(anim: CName) -> Void {
    this.m_animProxy = this.PlayLibraryAnimation(anim);
  }
}

public class NetworkMinigameBasicProgramController extends NetworkMinigameProgramController {

  public func ShowCompleted(revealLocalizedName: Bool) -> Void {
    inkWidgetRef.SetVisible(this.m_completedMarker, true);
    this.m_data.wasCompleted = true;
    if revealLocalizedName {
      inkTextRef.SetText(this.m_text, this.m_data.localizationKey);
    };
    this.PlayAnim(n"basic_access_unlocked");
  }
}

public class NetworkMinigameProgramListController extends inkLogicController {

  protected edit let m_programPlayerContainer: inkWidgetRef;

  protected edit let m_programNetworkContainer: inkWidgetRef;

  protected edit let m_programLibraryName: CName;

  protected let m_slotList: array<wref<NetworkMinigameProgramController>>;

  private let m_animProxy_02: ref<inkAnimProxy>;

  private edit let m_headerBG: inkWidgetRef;

  public final func Spawn(contents: array<ProgramData>) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(contents) {
      ArrayPush(this.m_slotList, this.SpawnSlot(contents[i]));
      i += 1;
    };
  }

  private final func SpawnSlot(data: ProgramData) -> wref<NetworkMinigameProgramController> {
    let toAppendTo: inkWidgetRef = this.GetDesignatedParent(data);
    let slot: wref<inkWidget> = this.SpawnFromLocal(inkWidgetRef.Get(toAppendTo), this.m_programLibraryName);
    let slotLogic: wref<NetworkMinigameProgramController> = slot.GetController() as NetworkMinigameProgramController;
    slotLogic.Spawn(data);
    return slotLogic;
  }

  private final func GetDesignatedParent(data: ProgramData) -> inkWidgetRef {
    switch data.type {
      case ProgramType.ExtraPlayerProgram:
        return this.m_programPlayerContainer;
      case ProgramType.ExtraServerProgram:
        return this.m_programNetworkContainer;
    };
    return this.m_programPlayerContainer;
  }

  public final func UpdatePartialCompletionState(progressList: array<ProgramProgressData>) -> Void {
    let j: Int32;
    let i: Int32 = 0;
    while i < ArraySize(progressList) {
      j = this.FindSlotIndexByID(progressList[i].id);
      if j >= 0 {
        this.m_slotList[j].UpdatePartialCompletionState(progressList[i]);
      };
      i += 1;
    };
  }

  public final func ShowCompleted(id: String, revealLocalizedName: Bool) -> Void {
    let i: Int32 = this.FindSlotIndexByID(id);
    if i >= 0 {
      this.m_slotList[i].ShowCompleted(revealLocalizedName);
    };
  }

  public final func PlaySideBarAnim() -> Void {
    inkWidgetRef.SetVisible(this.m_headerBG, true);
  }

  public final func ProcessListModified(shouldModify: Bool, playerProgramsAdded: array<ProgramData>, playerProgramsRemoved: array<ProgramData>) -> Void {
    let i: Int32;
    let j: Int32;
    let parentCompound: wref<inkCompoundWidget>;
    let parentCompoundRef: inkWidgetRef;
    if shouldModify {
      i = 0;
      while i < ArraySize(playerProgramsRemoved) {
        j = this.FindSlotIndexByID(playerProgramsRemoved[i].id);
        if j >= 0 {
          parentCompoundRef = this.GetDesignatedParent(playerProgramsRemoved[i]);
          parentCompound = inkWidgetRef.Get(parentCompoundRef) as inkCompoundWidget;
          parentCompound.RemoveChild(this.m_slotList[j].GetRootWidget());
          ArrayErase(this.m_slotList, j);
        };
        i += 1;
      };
      i = 0;
      while i < ArraySize(playerProgramsAdded) {
        ArrayPush(this.m_slotList, this.SpawnSlot(playerProgramsAdded[i]));
        i += 1;
      };
    };
  }

  private final func FindSlotIndexByID(id: String) -> Int32 {
    let data: ProgramData;
    let i: Int32 = 0;
    while i < ArraySize(this.m_slotList) {
      data = this.m_slotList[i].GetData();
      if Equals(id, data.id) {
        return i;
      };
      i += 1;
    };
    LogUIError("##############[hacking minigame] id not found " + id);
    return -1;
  }
}
