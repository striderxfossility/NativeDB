
public class TestRandomizationSupervisor extends ScriptedRandomizationSupervisor {

  public let firstWasGenerated: Bool;

  protected cb func OnBeginRandomization(out entries: array<RandomizationDataEntry>) -> Bool {
    let firstIndex: Int32;
    let lastIndex: Int32;
    let tmpEntry: RandomizationDataEntry;
    let size: Int32 = ArraySize(entries);
    let i: Int32 = 0;
    while i < size {
      if Equals(entries[i].id, "first") {
        firstIndex = i;
      } else {
        if Equals(entries[i].id, "last") {
          lastIndex = i;
        };
      };
      i += 1;
    };
    tmpEntry = entries[0];
    entries[0] = entries[firstIndex];
    entries[firstIndex] = tmpEntry;
    size -= 1;
    tmpEntry = entries[size];
    entries[size] = entries[lastIndex];
    entries[lastIndex] = tmpEntry;
    this.firstWasGenerated = false;
  }

  protected cb func OnCanBeGenerated(entry: RandomizationDataEntry) -> Bool {
    if Equals(entry.id, "last") {
      return !this.firstWasGenerated;
    };
    return true;
  }

  protected cb func OnMarkGenerated(entry: RandomizationDataEntry) -> Bool {
    if Equals(entry.id, "first") {
      this.firstWasGenerated = true;
    };
  }

  protected cb func OnEndRandomization() -> Bool {
    LogChannel(n"Test", "Randomization finished. First was generated: " + this.firstWasGenerated);
  }
}
