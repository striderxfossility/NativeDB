
public struct WorldMapUtils {

  public final static func CycleWorldMapFilter(currentFilter: gamedataWorldMapFilter, cycleNext: Bool) -> gamedataWorldMapFilter {
    let newFilterIdx: Int32;
    let options: gamedataWorldMapFilter[7];
    options[0] = gamedataWorldMapFilter.NoFilter;
    options[1] = gamedataWorldMapFilter.Quest;
    options[2] = gamedataWorldMapFilter.VehiclesForPurchaseFilter;
    options[3] = gamedataWorldMapFilter.Story;
    options[4] = gamedataWorldMapFilter.FastTravel;
    options[5] = gamedataWorldMapFilter.ServicePoint;
    options[6] = gamedataWorldMapFilter.DropPoint;
    let total: Int32 = ArraySize(options);
    let i: Int32 = 0;
    while i < total {
      if Equals(options[i], currentFilter) {
        newFilterIdx = i;
      };
      i += 1;
    };
    if cycleNext {
      newFilterIdx = (newFilterIdx + 1) % total;
    } else {
      newFilterIdx = newFilterIdx - 1;
      if newFilterIdx < 0 {
        newFilterIdx = total - 1;
      };
    };
    return options[newFilterIdx];
  }
}
