<aside class="lg:block flex-shrink-0 w-full lg:w-80 h-full bg-gray-100 lg:border-r hidden" style="position: relative;">
    <div style="overflow:visible;height:0;width:0">
        <div style="position: relative; height: 857px; width: 320px; overflow: auto; will-change: transform; direction: ltr;">
            <div>
                @if(isset($type))
                    @php
                        \App\Models\Type::chunk(200, function ($classTypes) use ($type) {
                            echo '<div style="content-visibility: auto">';
                                foreach ($classTypes as $classType) {

                                    $color = $classType->id == $type->id ?  "text-purple-500 font-bold" : "";
                                    $colorHead = '';

                                    if(isset($type->type))
                                        $colorHead = $classType->id == $type->type->id ?  "text-yellow-500 font-bold" : "";

                                    echo '<a id="class-' . $classType->id . '" class="' . $colorHead . ' ' . $color . ' flex items-center py-1 px-4 hover:bg-gray-200 transition duration-100" href="/classes/'.$classType->id.'/show">';
                                    echo $classType->name;
                                    echo '</a>';
                                }
                            echo '</div>';
                        });
                    @endphp

                    <script>
                        document.getElementById('class-{{$type->id}}').scrollIntoView();
                    </script>
                @else
                    @php
                        \App\Models\Type::chunk(200, function ($classTypes) {
                            echo '<div style="content-visibility: auto">';
                                foreach ($classTypes as $classType) {
                                    echo '<a id="class-' . $classType->id . '" class="flex items-center py-1 px-4 hover:bg-gray-200 transition duration-100" href="/classes/'.$classType->id.'/show">';
                                    echo $classType->name;
                                    echo '</a>';
                                }
                            echo '</div>';
                        });
                    @endphp
                @endif
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