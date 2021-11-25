<aside class="lg:block flex-shrink-0 w-full lg:w-80 h-full bg-gray-100 lg:border-r hidden" style="position: relative;">
    <div style="overflow:visible;height:0;width:0">
        <div style="position: relative; height: 857px; width: 320px; overflow: auto; will-change: transform; direction: ltr;">
            <div>
                
                @php
                    \App\Models\Enum::chunk(500, function ($enums) use ($enum) {
                        echo '<div style="content-visibility: auto">';
                            foreach ($enums as $enumHead) {

                                $color = $enumHead->id == $enum->id ?  "text-purple-500 font-bold" : "";
                                
                                echo '<a id="class-' . $enumHead->id . '" class="' . $color . ' flex items-center py-1 px-4 hover:bg-gray-200 transition duration-100" href="/enums/'.$enumHead->id.'/show">';
                                echo $enumHead->name;
                                echo '</a>';
                            }
                        echo '</div>';
                    });
                @endphp

                <script>
                    document.getElementById('class-{{$enum->id}}').scrollIntoView();
                </script>
            </div>
        </div>
    </div>
    <div class="resize-triggers">
        <div class="expand-trigger">
            <div style="width: 320px; height: 858px;"></div>
        </div>
        <div class="contract-trigger"></div>
    </div>
</aside>