
public class WorkspotMapData extends IScriptable {

  public let action: gamedataWorkspotActionType;

  public inline const let workspots: array<ref<WorkspotEntryData>>;

  public final const func FindFreeWorkspotRef() -> NodeRef {
    let workspotRef: NodeRef;
    let i: Int32 = 0;
    while i < ArraySize(this.workspots) {
      if this.workspots[i] == null {
      } else {
        if this.workspots[i].isEnabled && this.workspots[i].isAvailable {
          workspotRef = this.workspots[i].workspotRef;
        } else {
          i += 1;
        };
      };
    };
    return workspotRef;
  }

  public final const func FindFreeWorkspotData() -> ref<WorkspotEntryData> {
    let workspotData: ref<WorkspotEntryData>;
    let i: Int32 = 0;
    while i < ArraySize(this.workspots) {
      if this.workspots[i] == null {
      } else {
        if this.workspots[i].isEnabled && this.workspots[i].isAvailable {
          workspotData = this.workspots[i];
        } else {
          i += 1;
        };
      };
    };
    return workspotData;
  }

  public final const func GetFreeWorkspotsCount() -> Int32 {
    let count: Int32;
    let i: Int32 = 0;
    while i < ArraySize(this.workspots) {
      if this.workspots[i] == null {
      } else {
        if this.workspots[i].isEnabled && this.workspots[i].isAvailable {
          count += 1;
        } else {
          i += 1;
        };
      };
    };
    return count;
  }

  public final func ReleaseWorkspot(workspotRef: NodeRef) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.workspots) {
      if this.workspots[i] == null {
      } else {
        if Equals(this.workspots[i].workspotRef, workspotRef) {
          this.workspots[i].isAvailable = true;
        };
      };
      i += 1;
    };
  }

  public final func ReserveWorkspot(workspotRef: NodeRef) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.workspots) {
      if this.workspots[i] == null {
      } else {
        if Equals(this.workspots[i].workspotRef, workspotRef) {
          this.workspots[i].isAvailable = false;
        };
      };
      i += 1;
    };
  }
}

public class WorkspotMapperComponent extends ScriptableComponent {

  public inline const let m_workspotsMap: array<ref<WorkspotMapData>>;

  protected final func OnGameAttach() -> Void;

  protected final func OnGameDetach() -> Void;

  public final const func GetFreeWorkspotsCountForAIAction(aiAction: gamedataWorkspotActionType) -> Int32 {
    let count: Int32;
    let mapEntryIndex: Int32 = this.GetWorkspotMapEntryIdexForAIaction(aiAction);
    if mapEntryIndex >= 0 {
      count = this.GetFreeWorkspotsCount(mapEntryIndex);
    };
    return count;
  }

  public final const func GetFreeWorkspotRefForAIAction(aiAction: gamedataWorkspotActionType) -> NodeRef {
    let workspotRef: NodeRef;
    let mapEntryIndex: Int32 = this.GetWorkspotMapEntryIdexForAIaction(aiAction);
    if mapEntryIndex >= 0 {
      workspotRef = this.FindFreeWorkspotRef(mapEntryIndex);
    };
    return workspotRef;
  }

  public final const func GetFreeWorkspotDataForAIAction(aiAction: gamedataWorkspotActionType) -> ref<WorkspotEntryData> {
    let workspotData: ref<WorkspotEntryData>;
    let mapEntryIndex: Int32 = this.GetWorkspotMapEntryIdexForAIaction(aiAction);
    if mapEntryIndex >= 0 {
      workspotData = this.FindFreeWorkspotData(mapEntryIndex);
    };
    return workspotData;
  }

  public final const func GetNumberOfWorkpotsForAIAction(aiAction: gamedataWorkspotActionType) -> Int32 {
    let mapEntryIndex: Int32 = this.GetWorkspotMapEntryIdexForAIaction(aiAction);
    if mapEntryIndex < 0 {
      return 0;
    };
    return ArraySize(this.m_workspotsMap[mapEntryIndex].workspots);
  }

  private final const func GetWorkspotMapEntryIdexForAIaction(aiAction: gamedataWorkspotActionType) -> Int32 {
    let i: Int32 = 0;
    while i < ArraySize(this.m_workspotsMap) {
      if this.m_workspotsMap[i] == null {
      } else {
        if Equals(this.m_workspotsMap[i].action, aiAction) {
          return i;
        };
      };
      i += 1;
    };
    return -1;
  }

  private final const func GetFreeWorkspotsCount(mapEntryIndex: Int32) -> Int32 {
    let count: Int32;
    if this.m_workspotsMap[mapEntryIndex] == null {
      count = 0;
    };
    if mapEntryIndex >= 0 {
      count = this.m_workspotsMap[mapEntryIndex].GetFreeWorkspotsCount();
    };
    return count;
  }

  private final const func FindFreeWorkspotRef(mapEntryIndex: Int32) -> NodeRef {
    let workspotRef: NodeRef;
    if this.m_workspotsMap[mapEntryIndex] == null {
      return workspotRef;
    };
    if mapEntryIndex >= 0 {
      workspotRef = this.m_workspotsMap[mapEntryIndex].FindFreeWorkspotRef();
    };
    return workspotRef;
  }

  private final const func FindFreeWorkspotData(mapEntryIndex: Int32) -> ref<WorkspotEntryData> {
    let workspotData: ref<WorkspotEntryData>;
    if this.m_workspotsMap[mapEntryIndex] == null {
      return workspotData;
    };
    if mapEntryIndex >= 0 {
      workspotData = this.m_workspotsMap[mapEntryIndex].FindFreeWorkspotData();
    };
    return workspotData;
  }

  private final func ReleaseWorkspot(workspotRef: NodeRef) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_workspotsMap) {
      if this.m_workspotsMap[i] == null {
      } else {
        this.m_workspotsMap[i].ReleaseWorkspot(workspotRef);
      };
      i += 1;
    };
  }

  private final func ReserveWorkspot(workspotRef: NodeRef) -> Void {
    let i: Int32 = 0;
    while i < ArraySize(this.m_workspotsMap) {
      if this.m_workspotsMap[i] == null {
      } else {
        this.m_workspotsMap[i].ReserveWorkspot(workspotRef);
      };
      i += 1;
    };
  }

  protected cb func OnReserveWorkspot(evt: ref<OnReserveWorkspotEvent>) -> Bool {
    this.ReserveWorkspot(evt.workspotRef);
  }

  protected cb func OnReleaseWorkspot(evt: ref<OnReleaseWorkspotEvent>) -> Bool {
    this.ReleaseWorkspot(evt.workspotRef);
  }
}
