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
    RemoveNil

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
    MixEcho
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
    MII = {Project.load CWD#'mii.dj.oz'}
    %JOY = {Project.load CWD#'joy.dj.oz'}

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
            fun {MultEachAux Elem}
                Elem*Factor
            end
        in
            {Map L MultEachAux}
        end
    end

    % Merges two lists (Rec Ter)
    fun {MergeList A B}
        local 
            fun {MergeListAux A B Acc}
                case A#B of nil#nil then
                    Acc
                else 
                    case A of nil then 
                        {Append Acc B}
                    else
                        case B of nil then
                            {Append Acc A}
                        else 
                            {Browse A.1 + B.1}
                            {MergeListAux A.2 B.2 {Append Acc [A.1 + B.1]}}
                        end
                    end
                end
            end
        in
            {MergeListAux A B [first]}.2
        end
    end

    % Removes each nil item in a chord
    fun {RemoveNil Chord}
        case Chord of H|T then 
            case H of nil then 
                {RemoveNil T}
            else 
                H|{RemoveNil T}
            end
        else 
            nil
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
                case Music of Factor#Part then
                    {MultEach {Mix P2T Part} Factor}
                else 
                    nil 
                end
            end
            Mapped = {Map ToMerge MergeAux}
            Folded = {FoldL Mapped MergeList nil}
        in 
            {Browse Folded} 
            Folded
        end

        % Repeat function
        fun {MixRepeat Amount Music}
            if Amount == 1 then
              Music
            else
              {Append Music {MixRepeat (Amount - 1) Music}}
            end
        end

        % clip function
        fun {MixClip Low High Mu}
            local
                fun {Clip Elem}
                    if Elem < Low then Low
                    elseif Elem > High then High
                    else Elem
                    end
                end
            in
                {Map Mu Clip}
            end
        end

        % loop function
        fun {MixLoop Seconds Music}
            case Music of H|T then
                local 
                    MusicDuration = {IntToFloat {List.length Music}} / U
                in
                    if Seconds >= MusicDuration then
                        {Append Music {MixLoop (Seconds - MusicDuration) T}}
                    else 
                        {MixCut 0.0 Seconds Music}
                    end
                end
            else nil 
            end
        end

        % echo
        fun {MixEcho P2T Dur Factor M}
            local
                Second = {Flatten [partition([silence(duration:Dur)]) M]}
                ToMerge = [(1.0-Factor)#M Factor#Second]
                {Browse ToMerge}
            in
                {MixMerge P2T ToMerge}
            end
        end

        % cut function
        fun {MixCut StartTime EndTime M}
            local
                fun {MixCutAux Start End Music Counter}
                    if Start < 0.0 then
                        % if Start bound is lower than start of music
                        0.0|{MixCutAux Start+1.0 End Music Counter}
                    else
                        case Music of H|T then
                            if Counter < Start then % not yet in the interval considered
                                {MixCutAux Start End T Counter+1.0}
                            else % we're in the interval
                                if Counter >= End then nil % reached the end of the interval
                                else % Keep on adding elements
                                    H|{MixCutAux Start End T Counter+1.0}
                                end
                            end
                        else 
                            if Counter < End then % we did not reach the upper bound but the music is finished (add silence)
                                0.0|{MixCutAux Start End nil Counter+1.0}
                            else % end of the time and end of the list
                                nil
                            end
                        end
                    end
                end
                Start = StartTime * U
                End = EndTime * U
            in
                {MixCutAux Start End M 0.0}
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
            fun {MixChord Chord} 
                local
                    FChord = {RemoveNil Chord}

                    Len = {IntToFloat {List.length FChord}} % number of notes in Chord

                    % Divides each element of [L] by [Factor ]
                    fun {Divide L}
                        L/Len
                    end
                    
                    Samples = {Map FChord Aux}
                in
                {Map {FoldL Samples MergeList nil} Divide}
                end
            end
            
            % applies GetPoints to each element of [MusicEx]
            fun {PartMixAux Item}
                case Item of note(name:N octave:O sharp:S duration:D instrument:I) then
                    {Aux Item}
                
                [] silence(duration:D) then 
                    {GetPoints D 0.0 0.0}

                [] H|T then % is a chord
                    case H of note(name:N octave:O sharp:S duration:D instrument:I) then
                        {MixChord H}
                    else nil % undefined Item
                    end

                [] nil then nil

                else nil % undefined Item
                end  
            end
        in
            MusicExtended = {P2T Music}
            {Flatten {RemoveNil {Map MusicExtended PartMixAux}}}
        end
    end 

    % mix function (provides .wav files)
fun {Mix P2T Music}
    case Music of nil then nil 
    else
        local

            fun{MixItem Item}

                case Item of partition(P) then
                    {PartMix P2T P}

                [] samples(Sample) then
                    Sample

                [] wave(Path) then
                    {Project.readFile Path}

                [] merge(Muse) then
                    {MixMerge P2T Muse}

                [] echo(delay:D decay:F M) then 
                    {MixEcho P2T D F M}

                [] reverse(Muse) then
                    {Reverse {Mix P2T Muse}}

                [] repeat(amount:Amount Muse) then
                    {MixRepeat Amount {Mix P2T Muse}}

                [] cut(start:StartTime finish:EndTime M) then
                    if StartTime > EndTime then
                        nil
                    else
                        {MixCut StartTime EndTime {Mix P2T M}}
                    end

                [] loop(seconds:Seconds Music) then
                    {MixLoop Seconds {Mix P2T Music}}

                [] clip(low:Low high:High Mu) then
                    if Low > High then % if base case not respected
                        nil
                    else 
                        {MixClip Low High {Mix P2T Mu}} % use clip filter
                    end

                [] fade(start:S out:O Muse) then
                    {MixFade S O {Mix P2T Muse}}

                else nil % not supposed to happen
                end
            end
        in
            {Flatten {RemoveNil {Map Music MixItem}}}
        end
    end
end

    {Browse '----------------------------'}
    Start = {Time}
    %{Browse {Project.run Mix PartitionToTimedList [echo(decay:0.5 delay:0.5 [partition([a b c])])] 'out.wav' }}
    %{Test Mix PartitionToTimedList}
    % {Browse {Project.run Mix PartitionToTimedList [merge([
    %     0.5#[partition([a b c])]
    %     0.5#[partition([silence(duration:0.5)]) partition([a b c])]
    % ])] 'out.wav' }}
    {Browse {Project.run Mix PartitionToTimedList MII 'out.wav' }}
    %{Browse {MixLoop (1.0/U) [0.1 0.2 0.3]}}
    {Browse 'Time of execution:'}
    {Browse {IntToFloat {Time}-Start} / 1000.0}
end

% silence dans un accord (ok)
% accord vide -> remplacer par nil ()