local

    % See project statement for API details.
    % !!! Please remove CWD identifier when submitting your project !!!
    CWD = '/home/jabier/Desktop/OzPROJECT/MaestrOZ/Template/' % Put here the **absolute** path to the project files
    [Project] = {Link [CWD#'Project2022.ozf']}

    %%%%%%%%%%%%%%%%%%%FUNCTIONS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % utils
    Concat
    TotalDuration
    RoundedDiv
    GetPos
    NextNote
    NextChord
    GetH
    GetFreq
    Sample
    MultList
    MergeList
    MultEach
    MixRepeat
    MixCut

    % extended
    NoteToExtended
    ChordToExtended

    % transitions
    Drone
    Stretch
    Duration
    Transpose

    %main functions
    PartitionToTimedList
    Mix
    PartMix

    MergeAux
    MixMerge

    %%%%%%%%%%%%%%%%%%%%VARIABLES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    PI = 3.14159265358979
    U = 44100.0
    Music = {Project.load CWD#'mii.dj.oz'}

in

    %%%%%%%%%%%%%%%%%%%%%%%%UTILS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Appends [B] to [A]
    fun {Concat A B}
        case A of H|T then
            H|{Concat T B}
        else
            B
        end
    end

    % returns the total duration of [Partition]
    fun {TotalDuration Partition}
        local
            fun {TotalDurationAux Partition Acc} 
                case Partition of H|T then
                    if {Label H} == note then
                        {TotalDurationAux T Acc+H.duration}
                    else
                        {TotalDurationAux T Acc+H.1.duration}
                    end
                else Acc
                end
            end
        in
        {TotalDurationAux Partition 0.0}
        end
    end

    % returns the rounded division between A and B (A//B in python)
    fun {RoundedDiv A B}
        if B == 0 then 0
        else 
            {FloatToInt {IntToFloat A}/{IntToFloat B}}
        end
    end

    % returns the postition of a Note (Ex pos(c0) ==> 0)
    fun {GetPos Note}
        if Note.name == c then
            if Note.sharp then 2
            else 1
            end
        elseif Note.name == d then
            if Note.sharp then 4
            else 3
            end
        elseif Note.name == e then 5
        elseif Note.name == f then
            if Note.sharp then 7
            else 6
            end
        elseif Note.name == g then
            if Note.sharp then 9
            else 8
            end
        elseif Note.name == a then
            if Note.sharp then 11
            else 10
            end
        elseif Note.name == b then 12
        else ~1
        end
    end

    % returns the next notes (n tones)
    fun {NextNote N Note} Spectrum Start Index Oct FOct Res in
        Spectrum = s(c1 c#1 d1 d#1 e1 f1 f#1 g1 g#1 a1 a#1 b1)
        Start = {GetPos Note}

        if ((Start+N) mod 12) < 0 then
            Index = 12 + ((Start+N) mod 12)
        elseif ((Start+N) mod 12) > 0 then
            Index = ((Start+N) mod 12)
        else Index = 12
        end

        Res = {NoteToExtended Spectrum.Index}
        Oct = Note.octave + {RoundedDiv (Start+N) 12}

        if Oct > 10 orelse Oct < 0 then FOct = 0
        else FOct = Oct
        end

        note( % builds the final note to return
            duration:Note.duration
            instrument:Note.instrument
            name:Res.name
            octave:FOct 
            sharp:Res.sharp
        )
    end

    % returns the next notes (n tones)
    fun {NextChord N Chord}
        case Chord of H|T then
            {NextNote N H}|{NextChord N T}
        else nil
        end
    end

    % returns the height of a note (considering A4 as 0)
    fun {GetH Note} Pos in
        Pos = {GetPos Note} - 1
        {IntToFloat (Pos + (Note.octave*12) - 57)}
    end

    % returns the frequence of a note (Ex: GetFreq(a4) = 440)
    fun {GetFreq Note} Power H Final in
        H = {GetH Note}
        Power = {Pow 2.0 H/12.0}
        Final = Power*440.0
        Final
    end

    % return a sample following formula n°2
    fun {Sample F I}
        0.5*{Float.sin (2.0*PI*F*(I/U))}
    end

    % Multiplies each element of a list between them
    fun {MultList L} MultListAux in
        fun {MultListAux L Acc}
            case L of H|T then
                {MultListAux T Acc*H}
            else Acc
            end
        end

        {MultListAux L 1.0}
    end

    % mutltiplies each element of a list
    fun {MultEach L Factor}
        case L of H|T then 
            H*Factor|{MultEach T Factor}
        else nil 
        end
    end

    % Merges two lists
    fun {MergeList A B}
        case A#B of nil#nil then
            nil
        else
            case A of nil then 
                0.0 + B.1|{MergeList nil B.2}
            else 
                case B of nil then 0.0 + A.1|{MergeList A.2 nil}
                else
                    A.1 + B.1|{MergeList A.2 B.2}
                end
            end
        end
    end


    %%%%%%%%%%%%%%%%%%%%%%%%EXTENDED%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Translate a note to the extended notation.
    fun {NoteToExtended Note}
        if {Label Note} == note then 
            Note
        else
            case Note of Name#Octave then
            note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
            [] Atom then
                case {AtomToString Atom}
                of [_] then
                    note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
                [] [N O] then
                    note(name:{StringToAtom [N]} octave:{StringToInt [O]} sharp:false duration:1.0 instrument: none)
                end
            end
        end
    end

    % Translate a chord to the extended notation.
    fun {ChordToExtended Chord}
        case Chord of H|T then
            {NoteToExtended H}|{ChordToExtended T}
        else nil
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%TRANSITIONS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % adds [Amount] times the [Sound] to the partition
    fun {Drone Sound Amount}
        if Amount == 0 then nil
        else
            local ExtendedSound in
                case Sound of H|T then 
                    ExtendedSound = {ChordToExtended Sound}
                else ExtendedSound = {NoteToExtended Sound}
                end
            ExtendedSound|{Drone Sound Amount-1}
            end
        end
    end

    % stretches the duration of [Partition] by [Factor]
    fun {Stretch Factor Partition} % Factor must be a float
        local 

            fun {StretchChord Factor Chord}
                case Chord of H|T then 
                    note(
                        duration:(H.duration*Factor) 
                        instrument:(H.instrument) 
                        name:(H.name) 
                        octave:(H.octave) 
                        sharp:(H.sharp)
                        )| {StretchChord Factor T}
                else nil
                end
            end

            fun {StretchAux Factor Partition}
                case Partition of H|T then
                    case H of Head|Tail then
                        {StretchChord Factor H}|{Stretch Factor T}
                    [] silence(duration:D) then
                        silence(duration:Factor*H.duration)|{Stretch Factor T}
                    else
                        note(
                            duration:(H.duration*Factor) 
                            instrument:(H.instrument) 
                            name:(H.name) 
                            octave:(H.octave) 
                            sharp:(H.sharp)
                            )|{Stretch Factor T}
                    end
                else nil
                end
            end
        in
            {StretchAux Factor {PartitionToTimedList Partition}}
        end
    end

    % sets the total duration of the [Partition] to [Seconds]
    fun {Duration Seconds Partition} TD Coef in % [Seconds] must be a float
        local 
            fun {DurationAux Seconds Partition}
                TD = {TotalDuration Partition}
                Coef = Seconds/TD
                {Stretch Coef Partition}
            end
        in
            {DurationAux Seconds {PartitionToTimedList Partition}}
        end
    end      

    % Transposes [Partition] of [Semitones] semitones.
    fun {Transpose Semitones Partition} 
        local 
            fun {TransposeAux Semitones Partition}
                case Partition of H|T then
                    case H of note(name:N octave:O sharp:S duration:D instrument:I) then
                        {NextNote Semitones H}|{Transpose Semitones T}
                    else 
                        {NextChord Semitones H}|{Transpose Semitones T}
                    end
                else nil
                end
            end
        in
            {TransposeAux Semitones {PartitionToTimedList Partition}}
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%MAIN-FUNCTIONS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fun {PartitionToTimedList P}
        case P of H|T then

            case H of duration(seconds:S P) then
                {Concat {Duration H.seconds H.1}{PartitionToTimedList T}}

            [] stretch(factor:F P) then
                {Concat {Stretch H.factor H.1}{PartitionToTimedList T}}

            [] drone(note:N amount:A) then
                {Concat {Drone H.note H.amount}{PartitionToTimedList T}}

            [] transpose(semitones:S P) then
                {Concat {Transpose H.semitones H.1}{PartitionToTimedList T}}
            [] silence(duration:D) then
                H|{PartitionToTimedList T}

            else
                if {IsList H} then
                    {ChordToExtended H}|{PartitionToTimedList T}
                else
                    {NoteToExtended H}|{PartitionToTimedList T}
                end
            end
        else nil
        end
    end



    % merge function
    fun {MixMerge P2T ToMerge}
        fun {MergeAux Music}
            case Music of Factor#Part then {MultEach {PartMix P2T Part.1} Factor}
            else nil end
        end
    in {FoldR {Map ToMerge MergeAux} MergeList nil}
    end

    %Fonction qui échantillone la musique 
    fun {PartMix P2T Music}
        local 
            MusicExtended 

            % returns a list of points associated to a note and its duration
            fun {GetPoints Dur Freq I}
                if I == (Dur*U) then
                    nil
                else
                    {Sample Freq I}|{GetPoints Dur Freq I+1.0}
                end
            end

            % transforms Note (in order to use in map fun)  
            fun {Aux Note} {GetPoints Note.duration {GetFreq Note} 1.0} end

            % treats chord
            fun {MixChord Chord} Len Divide Samples in
                Len = {IntToFloat {List.length Chord}} % number of notes in Chord

                % Divides each element of [L] by [Factor ]
                fun {Divide L}
                    L/Len
                end

                Samples = {Map Chord Aux}
                {Map {FoldR Samples MergeList nil} Divide}
            end
            
            % applies GetPoints to each element of [MusicEx]
            fun {PartMixAux MusicEx}
                case MusicEx of H|T then
                    case H of note(name:N octave:O sharp:S duration:D instrument:I) then
                        {Concat {Aux H} {PartMixAux T}}
                    [] silence(duration:D) then 
                        {Concat {GetPoints H.duration 0.0 0.0} {PartMixAux T}}
                    [] H1|T1 then % is a chord
                        case H1 of note(name:N octave:O sharp:S duration:D instrument:I) then
                            {Concat {MixChord H} {PartMixAux T}}
                        else nil
                        end
                    else nil
                    end
                else nil
                end
            end
        in
            MusicExtended = {P2T Music}
            {PartMixAux MusicExtended}
        end
    end 

    fun {MixRepeat Amount Music}
        if Amount == 1.0 then
          Music
        else
          {Concat Music {MixRepeat (Amount - 1.0) Music}}
        end
    end

    fun {MixCut Low High Mu}
        case Mu of H|T then 
            if H < Low then 
                {Concat [Low] {MixCut Low High T}}
            elseif H > High then
                {Concat [High] {MixCut Low High T}}
            else 
                {Concat [H] {MixCut Low High T}}
            end
        else 
          nil
        end
    end

    fun {Mix P2T Music}
        case Music of H|T then
            case H of merge(M) then
                {Browse H.1}
                {Concat {MixMerge P2T H.1} {Mix P2T T}}
            [] partition(P) then
                {Concat {PartMix P2T H.1} {Mix P2T T}}
            [] repeat(amount:Amount Muse) then
                {Concat {MixRepeat Amount {Mix P2T H.1}} {Mix P2T T}}
            [] wave(Path) then
                {Concat {Project.readFile Path} {Mix P2T T}}
            [] reverse(Mus) then
                {Concat {Reverse {Mix P2T H.1}} {Mix P2T T}}
            [] samples(Sample) then 
                {Concat H.1 {Mix P2T T}}
            [] clip(low:Low high:High Mu) then
                if Low > High then
                    {Mix P2T T}
                else 
                    {Concat {MixCut Low High {Mix P2T H.1}} {Mix P2T T}}
                end
            else nil end
        else nil end
    end


    % MergeList
    % {Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}

    % Test du Merge
    %{Browse {Project.run Mix PartitionToTimedList [merge([0.4#partition([stretch(factor:120.0 [c4 e4 f4])]) 0.6#partition([d6 c3])])] 'out.wav'}}

    % Test du repeat
    %{Browse {Project.run Mix PartitionToTimedList [repeat(amount:3.0 [partition([a4 d4])])] 'out.wav'}}

    % Test du partition
    %{Browse {Project.run Mix PartitionToTimedList [partition([c4 d4 e4 f4])] 'out.wav'}}

    % Test du reverse
    %{Browse {Project.run Mix PartitionToTimedList [reverse([partition([a4 d4 e3 b4])]) ] 'out.wav'}}

    % Test du wave
    %{Browse {Project.run Mix PartitionToTimedList [wave('wave/animals/cow.wav')] 'out.wav'}}

    % Test du samples
    %{Browse {Project.run Mix PartitionToTimedList [samples({Mix PartitionToTimedList [partition([c3])]})] 'out.wav'}}

    % Test du clip
    {Browse {Project.run Mix PartitionToTimedList [clip(low:~0.01 high:0.01 [partition([c6])]) partition([c6])]  'out.wav' }}
end