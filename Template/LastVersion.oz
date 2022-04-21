local
    % See project statement for API details.
    % !!! Please remove CWD identifier when submitting your project !!!
    CWD = '/home/theo/Code/Oz/MaestrOZ/Template/' % Put here the **absolute** path to the project files
    [Project] = {Link [CWD#'Project2022.ozf']}
    Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime
  
    %%%%%%%%%%%%%%%%%UTILS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
    fun {Concat A B} % réalise la concaténation de deux listes
       case A of H|T then H|{Concat T B}
       [] nil then B
       end
    end
 
    fun {GetDuration Partition} % return la durée totale d'une partition
       local GetDurationAux in
          GetDurationAux = fun {$ Partition Acc}
             case Partition of nil then Acc
             [] H|T then
                if {IsExtendedNote H} then {GetDurationAux T Acc+H.duration} %si la head est une Extended note
                else {GetDurationAux T Acc+H.2} %si la head est un extended chord
                end
             end
          end
          {GetDurationAux Partition 0}
       end
    end
 
 
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
    % Translate a note to the extended notation.
    fun {NoteToExtended Note}
       case Note
       of Name#Octave then
          note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
       [] Atom then
          case {AtomToString Atom}
          of [_] then
             note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
          [] [N O] then
             note(name:{StringToAtom [N]}
                  octave:{StringToInt [O]}
                  sharp:false
                  duration:1.0
                  instrument: none)
          end
       end
    end
 
    % Fonction qui convertit un chord en Extended Chord
    fun {ChordToExtended Chord} % return un accord sous le format: [['liste des notes'], durée des notes]
       local
          ChordToExtendedAux = fun {$ Chord}
             case Chord
             of Note|Tail then
                {NoteToExtended Note}|{ChordToExtended Tail}
             else nil
             end
          end
       in
          [{ChordToExtendedAux Chord} Chord.1.duration]
       end
    end
 
    fun {IsNote Item}  %return true si Item est une note
       case Item of Name#Octave then true
       [] Atom then 
 
          case {AtomToString Atom}
          of [_] then true
 
          [] [N O] then true
 
          else false
          end
 
       else false
       end
    end
 
    fun {IsChord Item} %return true si Item est un accord
       case Item of H|T then
          if {isNote H} then true
          else false
          end
       else false
       end
    end
 
    fun {IsExtendedNote Item} %return true si Item est une Extended note
       if {IsRecord Item} then {Label Item} == note
       else false
       end
    end 
 
    fun {IsTransformation Item} % return true si Item est une transformation
       if {IsRecord Item} then
          if {Label Item} == duration then true
          elseif {Label Item} == stretch then true
          elseif {Label Item} == drone then true
          elseif {Label Item} == transpose then true
          else false 
          end
       else false
       end
    end
 
    fun {NextSemiTone Note} %return la Note suivante
       if Note == 'A' then 'B'
       elseif Note == 'B' then 'C'
       elseif Note == 'C' then 'D'
       elseif Note == 'D' then 'E'
       elseif Note == 'E' then 'F'
       elseif Note == 'F' then 'G'
       else 'A'
       end
    end
 
 
    fun {TransposeNote Note N} % tranforme Note d'un semi ton vers le haut
       if N == 0 then Note
       else
          if Note.name == 'E' orelse Note.name == 'B' then
             Note.name = {NextSemiTone Note.name}
             {TransposeNote Note N-1}
          else
             if Note.sharp then % si c'est un # alors on passe a la note suivante
                Note.sharp = false
                Note.name = {NextSemiTone Note.name}
                {TransposeNote Note N-1}
             else % sinon on ajoute juste un # a la note
                Note.sharp = true
                {TransposeNote Note N-1}
             end
          end
       end
    end
 
    fun {TransposeChord Chord N} %Transpose toutes les notes de l'accord de N demi tons
       local TransposeChordAux in
          TransposeChordAux = fun {$ List}
             case List of H|T then
                {TransposeNote H N}|{TransposeChordAux T N}
             else nil
             end
          end
          [{TransposeChordAux Chord.1 N} Chord.2]
       end
    end
 
    %TODO
    fun {Duration Seconds Partition}
       % Cette transformation fixe la durée de la partition au nombre de secondes indiqué. Il faut donc
       %adapter la durée de chaque note et accord proportionnellement à leur durée actuelle pour que
       %la durée totale devienne celle indiquée dans la transformation.
       local Coef FullDuration in
          FullDuration = {GetDuration Partition}
          Coef = Seconds div FullDuration
          {Stretch Coef Partition}
       end
    end
 
    fun {Stretch Factor Partition}
       %Cette transformation étire la durée de la partition par le facteur indiqué. Il faut donc étirer la
       %durée de chaque note et accord en conséquence.
       case Partition of H|T then
          if {IsExtendedNote H} then
             H.duration = H.duration*Factor
             H|{Stretch Factor T}
          else
             H.2 = H.2*Factor
             H|{Stretch Factor T}
          end
       else nil
       end
    end
 
    fun {Drone Item Amount}
       %Un bourdon (drone en anglais) est une répétition de notes (ou d'accords) identiques. Il faut
       %répéter la note ou l'accord autant de fois que la quantité indiquée par amount.
       if Amount == 0 then nil
       else
          if {IsNote Item} then
             {NoteToExtended Item}|{Drone Item Amount-1}
          elseif {IsChord Item} then
             {ChordToExtended Item}|{Drone Item Amount-1}
          else
             Item|{Drone Item Amount-1}
          end
       end
    end
 
    fun {Transpose Semitones Partition}
       %Cette transformation transpose la partition d'un certain nombre de demi-tons vers le haut
       %(nombre positif) ou vers le bas (nombre négatif). Référez vous à la section sur les notes ci-dessus
       %pour plus de détails concernant les distances en demi-tons entre les notes. Par
       %exemple, transposer A4 de 4 demi-tons vers le haut donne C#5 (par intervalle d'un demi-ton:
       %A4, A#4, B4, C5, C#5).
       
       case Partition of H|T then
          if {IsExtendedNote H} then 
             {TransposeNote H Semitones}|{Transpose Semitones Partition}
          else
             {TransposeChord H Semitones}|{Transpose Semitones Partition}
          end
       else nil
       end
    end
    
    
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
    fun {PartitionToTimedListAux Partition Head}
       case Partition of
       H|T then
 
          if {IsNote H} then 
             {NoteToExtended H}|{PartitionToTimedList T Head} %Etend la note
 
          elseif {IsChord H} then 
             {ChordToExtended H}|{PartitionToTimedList T Head} %Etend l'accord
 
          elseif {IsTransformation H} then 
             % should use pattern matching
             if {Label H} == duration then %done
                {Duration H.seconds Head} % problème car Head ne se finit pas (pas de nil a la fin)
 
             elseif {Label H} == stretch then %done
                {Stretch H.factor Head} % problème car Head ne se finit pas (pas de nil a la fin)
 
             elseif {Label H} == drone then %ajoute amount note à la partition
                {Concat {Drone H.note H.amount} {PartitionToTimedList T Head}} % problème car Head ne se finit pas (pas de nil a la fin)
 
             elseif {Label H} == transpose then 
                {Transpose H.semitones Head} % problème car Head ne se finit pas (pas de nil a la fin)
 
             end
          else H|{PartitionToTimedList T} % on a un(e) accord/note étendu(e)
          end
       [] nil then nil
       end
    end
 
    fun {PartitionToTimedList Partition}
       case Partition of H|T then
          {PartitionToTimedListAux Partition H}
       else nil
       end
    end
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
    fun {Mix P2T Music}
       % TODO
       {Project.readFile CWD#'wave/animals/cow.wav'}
    end
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
    Music = {Project.load CWD#'joy.dj.oz'}
    Start
 
    % Uncomment next line to insert your tests.
    % \insert '/full/absolute/path/to/your/tests.oz'
    % !!! Remove this before submitting.
 in
    {Browse '-'}
    %Start = {Time}
 
    % Uncomment next line to run your tests.
    % {Test Mix PartitionToTimedList}
 
    % Add variables to this list to avoid "local variable used only once"
    % warnings.
    %{ForAll [NoteToExtended Music] Wait}
    
    % Calls your code, prints the result and outputs the result to `out.wav`.
    % You don't need to modify this.
    %{Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}
    
    % Shows the total time to run your code.
    %{Browse {IntToFloat {Time}-Start} / 1000.0}
 end
 