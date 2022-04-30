local

    % Diego Troch Noma: 0725200
    % Théodore Cousin Noma: 47202000

    \insert 'tests.oz'
    % See project statement for API details.
    % !!! Please remove CWD identifier when submitting your project !!!
    %CWD = '/home/jabier/Desktop/OzPROJECT/MaestrOZ/Template/' % dieg
    CWD = '/home/theo/Code/Oz/MaestrOZ/Template/' %theo laptop
    %CWD = '/home/aloka/Unif/BAC2/Q2/Para/MaestrOZ/MaestrOZ/Template/' %theo pc fixe
    [Project] = {Link [CWD#'Project2022.ozf']}
    Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

    %%%%%%%%%%%%%%%%%%%FUNCTIONS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % utils
    Start
    TotalDuration
    GetPos
    NextNote
    NextChord
    GetH
    GetFreq
    Sample
    MultList
    MergeList
    MultEach

    % extended
    NoteToExtended
    ChordToExtended
    SilenceToExtended

    % transitions
    Drone
    Stretch
    Duration
    Transpose

    % filters
    MixRepeat
    MixClip
    MixMerge
    MixCut
    MixLoop
    MexIcho
    MixMergeMEXICO
    MixFade


    %main functions
    PartitionToTimedList
    Mix
    PartMix

    %%%%%%%%%%%%%%%%%%%%VARIABLES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    PI = 3.14159265358979
    U = 44100.0
    %TEST = {Project.load CWD#'test.dj.oz'}
    %MII = {Project.load CWD#'mii.dj.oz'}
    JOY = {Project.load CWD#'joy.dj.oz'}

in

    %%%%%%%%%%%%%%%%%%%%%%%%UTILS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % returns the total duration of [Partition]
    fun {TotalDuration Partition}
        local
            fun {TotalDurationAux Partition Acc} 
                case Partition of H|T then
                    case H of note(duration:D name:N octave:O sharp:S instrument:I) then
                        {TotalDurationAux T Acc+D}
                    [] silence(duration:D) then
                        {TotalDurationAux T Acc+D}
                    [] nil then
                        {TotalDurationAux T Acc}
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
        if Start+N < 0 then 
            Oct = Note.octave - 1 + (Start+N) div 12
        else
            Oct = Note.octave + (Start+N-1) div 12
        end

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

    % Multiplies each element of a list between them (Rec Ter)
    fun {MultList L} MultListAux in
        fun {MultListAux L Acc}
            case L of H|T then
                {MultListAux T Acc*H}
            else Acc
            end
        end

        {MultListAux L 1.0}
    end

    % mutltiplies each element of a list (Rec Ter)
    fun {MultEach L Factor}
        local 
            fun {MultEachAux L Factor Acc}
                case L of H|T then 
                    {MultEachAux T Factor {Append Acc [Factor*H]}}
                else Acc.2
                end
            end
        in
            {MultEachAux L Factor [head]}
        end
    end

    % Merges two lists (Rec Ter)
    fun {MergeList A B}
        local 
            fun {MergeListAux A B Acc}
                {Browse Acc}
                case A#B of nil#nil then 
                    {Browse 'C1'}
                    Acc
                else 
                    case A of nil then 
                        {Browse 'C2'}
                        {Append Acc B}
                    else
                        case B of nil then 
                            {Browse 'C3'}
                            {Append Acc A}
                        else 
                            {MergeListAux A.2 B.2 {Append Acc [A.1 + B.1]}}
                        end
                    end
                end
            end
        in
            {MergeListAux A B [first]}.2
        end
    end


    %%%%%%%%%%%%%%%%%%%%%%%%EXTENDED%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Translate a note to the extended notation.
    fun {NoteToExtended Note}
        case Note of note(name:N octave:O sharp:S duration:D instrument:I) then 
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
                else nil
                end
            else nil
            end
        end
    end

    % Translate a silence to the extended notation.
    fun {SilenceToExtended Silence}
        case Silence of silence(duration:D) then Silence
        else silence(duration:1.0) end
    end

    % Translate a chord to the extended notation.
    fun {ChordToExtended Chord}
        case Chord of H|T then
            case H of silence then
                {SilenceToExtended H}|{ChordToExtended T}
            [] silence(duration:D) then
                {SilenceToExtended H}|{ChordToExtended T}
            else
                {NoteToExtended H}|{ChordToExtended T}
            end
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
                [] silence(duration:D) then
                    ExtendedSound = {SilenceToExtended Sound}
                [] silence then 
                    ExtendedSound = {SilenceToExtended Sound}
                [] nil then ExtendedSound = nil
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
                local
                    fun {StretchChordAux Factor Chord Acc}
                        case Chord of H|T then 
                            case H of note(duration:D instrument:I sharp:S name:N octave:O) then
                                {StretchChordAux Factor T {Append Acc [note(duration:(D*Factor) instrument:I name:N octave:O sharp:S)]}}
                            [] silence(duration:D) then {StretchChordAux Factor T {Append Acc [silence(duration:D*Factor)]}}
                            else nil
                            end
                        else Acc
                        end
                    end
                in
                    {StretchChordAux Factor Chord [first]}.2
                end
            end

            fun {StretchAux Factor Partition Acc}
                case Partition of H|T then
                    case H of Head|Tail then
                        {StretchAux Factor T {Append Acc [{StretchChord Factor H}]}}
                    [] silence(duration:D) then
                        {StretchAux Factor T {Append Acc [silence(duration:Factor*D)]}}
                    [] note(duration:D instrument:I sharp:S name:N octave:O) then
                        {StretchAux Factor T {Append Acc [note(duration:(D*Factor) instrument:I name:N octave:O sharp:S)]}}
                    [] nil then 
                        {StretchAux Factor T {Append Acc [nil]}}
                    else nil end
                else Acc
                end
            end
        in
            {StretchAux Factor {PartitionToTimedList Partition} [first]}.2
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
                    [] silence(duration:D) then
                        H|{Transpose Semitones T}
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

    %%%%%%%%%%%%%%%%%%%%%%%%FILTERS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % merge function
        fun {MixMerge P2T ToMerge}
            fun {MergeAux Music}
                case Music of Factor#Part then {MultEach {PartMix P2T Part.1} Factor}
                else nil end
            end
        in {FoldR {Map ToMerge MergeAux} MergeList nil}
        end

        % merge function
        fun {MixMergeMEXICO ToMerge}
            fun {MergeAux Music}
                case Music of Factor#Part then {MultEach Part Factor}
                else nil end
            end
        in {FoldR {Map ToMerge MergeAux} MergeList nil}
        end

        % Repeat function
        fun {MixRepeat Amount Music}
            if Amount == 1.0 then
              Music
            else
              {Append Music {MixRepeat (Amount - 1.0) Music}}
            end
        end

        % clip function
        fun {MixClip Low High Mu}
            case Mu of H|T then 
                if H < Low then 
                    {Append [Low] {MixClip Low High T}}
                elseif H > High then
                    {Append [High] {MixClip Low High T}}
                else 
                    {Append [H] {MixClip Low High T}}
                end
            else 
              nil
            end
        end

        % loop function
        fun {MixLoop Seconds Music} MusicDuration in
            MusicDuration = {IntToFloat {List.length Music}} / 44100.0
            if Seconds >= MusicDuration then
                {Append Music {MixLoop (Seconds - MusicDuration) Music}}
            else 
              {MixCut 0.0 Seconds 0.0 Music}
            end
        end


        % echo
        fun {MexIcho Duracion Factor M}
            local 
                Temporal Silencio 
            in
                fun{Silencio ElAccumulador}
                case ElAccumulador of 1.0 then
                      0.0
                     else
                        0.0 | {Silencio (ElAccumulador - 1.0)}
                    end
                end
                    Temporal = {Append {Silencio (Duracion*44100.0)} M}
                    {MixMergeMEXICO [1.0#M Factor#Temporal]}
            end
        end
        

        % fade

        % cut function
        fun {MixCut StartTime EndTime Counter M}
            case M of H|T then
                if Counter =< (StartTime * 44100.0) then
                    {MixCut StartTime EndTime (Counter+1.0) T}
                else
                    if Counter >= (EndTime * 44100.0) then
                        nil
                    else {Append [H] {MixCut StartTime EndTime (Counter+1.0) T}}
                    end
                end
            else 
                if Counter =< (EndTime * 44100.0) then
                    {Append [0.0] {MixCut StartTime EndTime (Counter+1.0) nil}}
                else 
                    nil
                end
            end
        end

        % fade 
        fun {MixFade Start Out Music}
            local
                DurS = Start * U
                % deals with the start of the music
                fun {FadeStart Music I Coef}
                    case Music of H|T then
                        if I == DurS then
                            Music
                        else
                            H*Coef|{FadeStart T I+1.0 I/DurS}
                        end
                    else nil end
                end 

                % deals with the end of the music
                fun {FadeEnd Music}
                    local 
                        MusicReversed = {Reverse Music}
                        MusicProcessed = {FadeStart MusicReversed 0.0 0.0}
                    in
                        {Reverse MusicProcessed}
                    end
                end
                MusicS
            in
                MusicS = {FadeStart Music 0.0 0.0}
                {FadeEnd MusicS}
            end
        end
    

    %%%%%%%%%%%%%%%%%%%%%%%%MAIN-FUNCTIONS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fun {PartitionToTimedList P}
        case P of H|T then
            case H of duration(seconds:S P) then % duration transformation
                {Append {Duration S P}{PartitionToTimedList T}}

            [] note(duration:D name:N octave:O sharp:S instrument:I) then
                {NoteToExtended H}|{PartitionToTimedList T}

            [] stretch(factor:F P) then % stretch transformation
                {Append {Stretch F P}{PartitionToTimedList T}}

            [] drone(note:N amount:A) then % drone transformation
                {Append {Drone N A}{PartitionToTimedList T}}

            [] transpose(semitones:S P) then % transpose transformation
                {Append {Transpose S P}{PartitionToTimedList T}}

            [] silence then % case of silence
                {SilenceToExtended silence}|{PartitionToTimedList T}

            [] silence(duration:D) then % silence
                H|{PartitionToTimedList T}

            [] nil then
                nil|{PartitionToTimedList T}

            else
                if {IsList H} then % chord
                    if {Length H} == 0 then nil
                    else {ChordToExtended H}|{PartitionToTimedList T} end
                else % note
                    {NoteToExtended H}|{PartitionToTimedList T}
                end
            end
        else nil
        end
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
                        {Append {Aux H} {PartMixAux T}}
                    [] silence(duration:D) then 
                        {Append {GetPoints D 0.0 0.0} {PartMixAux T}}
                    [] H1|T1 then % is a chord
                        case H1 of note(name:N octave:O sharp:S duration:D instrument:I) then
                            {Append {MixChord H} {PartMixAux T}}
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

    % mix function (provides .wav files)
    fun {Mix P2T Music}

        case Music of H|T then

            case H of merge(Muse) then
                {Append {MixMerge P2T Muse} {Mix P2T T}}

            [] partition(P) then
                {Append {PartMix P2T P} {Mix P2T T}}

            [] repeat(amount:Amount Muse) then
                {Append {MixRepeat Amount {Mix P2T Muse}} {Mix P2T T}}

            [] wave(Path) then
                {Append {Project.readFile Path} {Mix P2T T}}

            [] reverse(Muse) then
                {Append {Reverse {Mix P2T Muse}} {Mix P2T T}}

            [] samples(Sample) then 
                {Append Sample {Mix P2T T}}

            [] clip(low:Low high:High Mu) then
                if Low > High then % if base case not respected
                    {Mix P2T T}
                else 
                    {Append {MixClip Low High {Mix P2T Mu}} {Mix P2T T}} % use clip filter
                end

            [] cut(start:StartTime finish:EndTime M) then
                if StartTime > EndTime then
                    {Mix P2T T}
                else
                    {Append {MixCut StartTime EndTime 0.0 {Mix P2T M}} {Mix P2T T}}
                end

            [] loop(seconds:Seconds Music) then
                {Append {MixLoop Seconds {Mix P2T Music}} {Mix P2T T}}

            [] echo(delay:Duracion decay:Factor M) then 
                {Append {MexIcho Duracion Factor {Mix P2T M}} {Mix P2T T}}

            [] fade(start:S out:O Muse) then
                {Append {MixFade S O {Mix P2T Muse}} {Mix P2T T}}

            else nil end % not supposed to happen

        else nil end % reached the end of the list
    end

    {Browse '----------------------------'}
    Start = {Time}
    %{Browse {PartitionToTimedList MII}}
    %{Browse {Project.run Mix PartitionToTimedList JOY 'out.wav' }}
    {Test Mix PartitionToTimedList}
    {Browse 'Time of execution:'}
    {Browse {IntToFloat {Time}-Start} / 1000.0}
end

% silence dans un accord (ok)
% accord vide -> remplacer par nil ()