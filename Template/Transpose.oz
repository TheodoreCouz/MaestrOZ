declare 
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
                        {MergeListAux A.2 B.2 {Append Acc [A.1 + B.1]}}
                    end
                end
            end
        end
    in
        {MergeListAux A B [first]}.2
    end
end

A = [0.0 0.0 0.0 0.0 0.0 1.0]
B = [1.0 1.0 1.0 1.0]

{Browse {MergeList A B}}