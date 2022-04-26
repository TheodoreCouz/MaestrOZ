\insert 'codeNew.oz'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%UTILS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Concat
{Browse 'TEST: Concat'}
declare
A = [1 2 3]
B = [4 5 6]
{Browse {Concat A B}} % should print [1 2 3 4 5 6]

% TotalDuration
{Browse 'TEST: TotalDuration'}
declare
P = {PartitionToTimedList [c3 c3 c3 [c3 c4 c5]]}
%{Browse P}
{Browse {TotalDuration P}} % should print 4

%RoundedDiv
declare 
A = ~14
B = 12
{Browse {RoundedDiv A B}} % should print 1

% NextNote
declare
Note = {NoteToExtended c#1}
{Browse {NextNote 123 Note}}

% NextChord
declare
Chord = {ChordToExtended [c1 c2 c3]}
%{Browse Chord}
{Browse {NextChord ~12 Chord}}

% GetPos
{Browse {GetPos {NoteToExtended c0}}} % should print 1

%GetH
{Browse {GetH {NoteToExtended a4}}} % should print 0

%GetFreq
{Browse {GetFreq {NoteToExtended c4}}}
{Browse {GetFreq {NoteToExtended c5}}}

% Sample
{Browse {Sample {NoteToExtended a4} 0.0}}

% MultList
{Browse {MultList [1.0 2.0 3.0]}}

% MergeList
{Browse {MergeList [1.0 1.0 1.0] [1.0 1.0]}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%TO EXTENDED%%%%%%%%%%%%%%%%%%%%%%%%%%

% NoteToExtended
{Browse 'TEST: NoteToExtended'}
declare
Note = {NoteToExtended c3}
Note2 = {NoteToExtended Note}
{Browse Note} % should print "note(duration:1 instrument:none name:c octave:3 sharp:false)"
{Browse Note2} % should print "note(duration:1 instrument:none name:c octave:3 sharp:false)"

% ChordToExtended
{Browse 'TEST: ChordToExtended'}
declare 
Note = {NoteToExtended c3}
Chord = {ChordToExtended [c3 c3 c3]}
Chord2 = {ChordToExtended [c3 Note c3]}
{Browse Chord} % should print [note(duration:1 instrument:none name:c octave:3 sharp:false) ... 3 times]
{Browse Chord2} % should print [note(duration:1 instrument:none name:c octave:3 sharp:false) ... 3 times]

%%%%%%%%%%%%%%%%%%%%%%%%%%TRANSITIONS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Drone Transition
{Browse 'TEST: Drone'}
declare
Note = {NoteToExtended c3}
Flat = {PartitionToTimedList [drone(note:c3 amount:2) c4 drone(note:[c5 c5 c5] amount:2)]}
{Browse Flat}

% Duration Transition
{Browse 'TEST: Duration'}
{Browse {Duration 4.0 [c1 c3]}} % each note should have a duration of 6 seconds

% Stretch Transition
{Browse 'TEST: Stretch'}
declare 
{Browse {Stretch 3.0 [c1 c2]}} % each note should have a duration of 0.5 seconds
Flat2 = {Stretch 0.5 Flat}
{Browse {Stretch 3.0 Flat2}}


% Transpose Transistion
{Browse 'TEST: Transpose'}
{Browse {Stretch 2.0 {Transpose 12 [c1 c2]}}}

%%%%%%%%%%%%%%%%%%%% GLOBAL TEST(S) FOR PARTITION TO TIMED LIST %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% only notes

{Browse 'Notes only'}
{Browse {PartitionToTimedList [c1 c2]}}

{Browse 'Notes and Chords'}
{Browse {PartitionToTimedList [c1 c2 [c1 c4]]}}

{Browse 'Drone transformation'}
{Browse {PartitionToTimedList [drone(amount:4 note:c1)]}}

{Browse 'Duration transformation'}
{Browse {PartitionToTimedList [duration(seconds:4.0 partition:[c1 c3])]}}

{Browse 'Stretch transformation'}
{Browse {PartitionToTimedList [stretch(factor:2.0 partition:[d3 d7])]}}

{Browse 'Transpose transformation'}
{Browse {PartitionToTimedList [c1 transpose(semitones:12 partition:[c2 c4])]}}

{Browse 'Complex case'}
{Browse {PartitionToTimedList [c1 transpose(semitones:12 partition:([stretch(factor:2.0 partition:([duration(seconds:4.0 partition:([drone(amount:4 note:c1)]))]))]))]}}

declare

% returns a list of points associated to a note and its duration
fun {GetPoints Note Freq I}
    if I == ({IntToFloat Note.duration}*U) then
        nil
    else
        {Sample Freq I}|{GetPoints Note Freq I+1.0}
    end
end

Note = {NoteToExtended c2}
%{Browse {GetFreq Note}}

{Browse {IntToFloat Note.duration}}

{Browse Note.duration*44100.0}
{Browse {GetPoints Note {GetFreq Note} 1.0}}

for I in {PartMix PartitionToTimedList [c1 c2]} do
    {Browse I}
end

{Browse {Project.run Mix PartitionToTimedList [c4 d4 e4 f4] 'out.wav'}}

{Browse {List.length [1 2 3]}}


