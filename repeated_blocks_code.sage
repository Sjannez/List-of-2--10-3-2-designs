#This is a (not so efficient) implementation of the algorithm described in 
#"A complete census of (10,3,2) block designs and of mendelsohn triple systems of order ten. IV. (10, 3, 2) block designs with repeated blocks."
#by B. Ganter, A. Gülzow, R. A. Mathon, and A. Rosa.
#It computes all 2-(10,3,2) designs with repeated blocks.
#For our application, we needed to convert them to graphs with a 3-regular coclique.
#The designs themselves are printed at the end of the code.

import numpy as np
import itertools

#remove isomorphic copies from list of graphs
def filterIso(graphlist):
    unique = []
    done = np.zeros(len(graphlist), dtype=int)
    for i in range(len(graphlist)):
        if done[i] == 1: continue
        G = graphlist[i]
        unique.append(G)
        for j in range(i+1, len(graphlist)):
            if done[j] == 1: continue
            if G.is_isomorphic(graphlist[j]):
                done[j] = 1
    return unique
	
#convert design to graph
def DtoG(D,s):
    G = Graph(len(D)+s)
    for i in range(len(D)):
        G.add_edges((b,i+s) for b in D[i])
    return G

#put cycles in stadardardized form
def shiftToMin(C):
    m = C.index(min(C))
    Cmin = [C[(i + m) % len(C)] for i in range(len(C))]
    return Cmin

def minFlip(C): #after shift
    flipC = [C[0]] + [C[len(C) - 1 - i] for i in range(len(C)-1)]
    return min(C,flipC)

#remove duplicate cycles
def filterDupes(Clist):
    unique = []
    done = np.zeros(len(Clist), dtype=int)
    for i in range(len(Clist)):
        if done[i] == 1: continue
        C = Clist[i]
        unique.append(C)
        for j in range(i+1, len(Clist)):
            if done[j] == 1: 
                continue
            if C == Clist[j]:
                done[j] = 1
    return unique

#compute 2-factorizations (partitions of the edges into cycles)
def twoFacts(Clist,cur,i):
    output = []
    flatCur = [y for x in cur for y in x]
    if len(flatCur) == 7:
        return [cur]
    opts = [Clist[j] for j in range(i+1,len(Clist)) if len([x for x in Clist[j] if x in flatCur]) == 0 and len(Clist[j]) <= 7-len(flatCur)]
    for j in range(len(opts)):
        output += twoFacts(opts,cur+[opts[j]],j)
    return output
	
#
def getTriples(Tlist,cur,A,i):
    if len(cur) == 3:
        return [cur]
    output = []
    cycleEdges = [sorted((C[j],C[(j+1)%len(C)])) for T in cur for C in T for j in range(len(C))]
    for j in range(max(0,i),len(Tlist)):
        T = Tlist[j] 
        edgesT = [sorted((C[j],C[(j+1)%len(C)])) for C in T for j in range(len(C))]
        allEdges = edgesT + cycleEdges
        bad = False
        for e in allEdges:
            if len([f for f in allEdges if f == e]) > A[e[0],e[1]]:
                bad = True
                break
        if not bad:
            output += getTriples(Tlist,cur+[Tlist[j]],A,j)
    return output
	
#application-specific code to turn a design into a graph
def tripsToG(trips,Dsmall):
    toCheck = []
    for Tset in trips:
        edgeSet0 = [sorted((C[j],C[(j+1)%len(C)])) for C in Tset[0] for j in range(len(C))]
        edgeSet1 = [sorted((C[j],C[(j+1)%len(C)])) for C in Tset[1] for j in range(len(C))]
        edgeSet2 = [sorted((C[j],C[(j+1)%len(C)])) for C in Tset[2] for j in range(len(C))]
        D = Dsmall + [[7,8,9],[7,8,9]] + [[e[0],e[1],7] for e in edgeSet0] + [[e[0],e[1],8] for e in edgeSet1] + [[e[0],e[1],9] for e in edgeSet2]
        G = DtoG(D,10)
        toCheck.append(G)
    return toCheck
	
#string -> design
def decodeDirect(s,b):
    D = []
    for i in range(b):
        B = [s[i+b*j] for j in range(len(s)/b)]
        D.append([int(b) for b in B])
    return D

	

#case 0 from Table 1 in the article

D0 = '000112312425343654656' 				#design D0 from article
D0 = decodeDirect(D0,7) 					#convert to list of lists
G0 = graphs.CompleteGraph(7) 				#graph G0 from article

#find induced cycles of G0, convert to standard form and filter dupes 
cycles = [graphs.CycleGraph(3), graphs.CycleGraph(4), graphs.CycleGraph(5), graphs.CycleGraph(7)]	
inducedC = [list(G0.subgraph_search_iterator(G,induced=False)) for G in cycles]
inducedC = [[shiftToMin(C) for C in L] for L in inducedC]
inducedC = [[minFlip(C) for C in L] for L in inducedC]
inducedC = [filterDupes(L) for L in inducedC]
flatList = [y for x in inducedC for y in x]

T0 = twoFacts(flatList,[],-1)				#compute 2-factorizations using list of cycles
trips0 = getTriples(T0,[],G0.am(),-1)		#convert to lists of blocks
toCheck0 = tripsToG(trips0,D0)				#merge partial designs with D0 and convert to graphs
filter0 = filterIso(toCheck0)				#remove isomorphic copies


#repeat for case 1-9:

D1 = '000133411224552345666'
D1 = decodeDirect(D1,7)
G1 = Graph(7,multiedges=True)
G1.add_edges([(0,3),(0,4),(0,5),(0,5),(0,6),(0,6),(1,3),(1,4),(1,4),(1,5),(1,6),(1,6),(2,3),(2,3),(2,4),(2,5),(2,6),(2,6),(3,4),(3,5),(4,5)])

cycles = [graphs.CycleGraph(3), graphs.CycleGraph(4), graphs.CycleGraph(5), graphs.CycleGraph(7)]
G1flat = G1.to_simple()
inducedC = [list(G1flat.subgraph_search_iterator(G,induced=False)) for G in cycles]
inducedC = [[[0,5],[0,6],[1,4],[1,6],[2,3],[2,6]]] + inducedC
inducedC = [[shiftToMin(C) for C in L] for L in inducedC]
inducedC = [[minFlip(C) for C in L] for L in inducedC]
inducedC = [filterDupes(L) for L in inducedC]
flatList = [y for x in inducedC for y in x]

T1 = twoFacts(flatList,[],-1)
trips1 = getTriples(T1,[],G1.am(),-1)
toCheck1 = tripsToG(trips1,D1)
filter1 = filterIso(toCheck1)


D2 = '000123411324552453666'
D2 = decodeDirect(D2,7)
G2 = Graph(7,multiedges=True)
G2.add_edges([(0,2),(0,3),(0,4),(0,5),(0,6),(0,6),(1,3),(1,4),(1,5),(1,5),(1,6),(1,6),(2,3),(2,4),(2,5),(2,5),(2,6),(3,4),(3,4),(3,6),(4,5)])

cycles = [graphs.CycleGraph(3), graphs.CycleGraph(4), graphs.CycleGraph(5), graphs.CycleGraph(7)]
G2flat = G2.to_simple()
inducedC = [list(G2flat.subgraph_search_iterator(G,induced=False)) for G in cycles]
inducedC = [[[0,6],[1,6],[1,5],[2,5],[3,4]]] + inducedC
inducedC = [[shiftToMin(C) for C in L] for L in inducedC]
inducedC = [[minFlip(C) for C in L] for L in inducedC]
inducedC = [filterDupes(L) for L in inducedC]
flatList = [y for x in inducedC for y in x]

T2 = twoFacts(flatList,[],-1)
trips2 = getTriples(T2,[],G2.am(),-1)
toCheck2 = tripsToG(trips2,D2)
filter2 = filterIso(toCheck2)


D3 = '000123311525442463656'
D3 = decodeDirect(D3,7)
G3 = Graph(7,multiedges=True)
G3.add_edges([(0,2),(0,3),(0,3),(0,4),(0,5),(0,6),(1,3),(1,4),(1,5),(1,5),(1,6),(1,6),(2,3),(2,4),(2,4),(2,5),(2,6),(3,5),(3,6),(4,5),(4,6)])

cycles = [graphs.CycleGraph(3), graphs.CycleGraph(4), graphs.CycleGraph(5), graphs.CycleGraph(7)]
G3flat = G3.to_simple()
inducedC = [list(G3flat.subgraph_search_iterator(G,induced=False)) for G in cycles]
inducedC = [[[1,6],[1,5],[2,4],[0,3]]] + inducedC
inducedC = [[shiftToMin(C) for C in L] for L in inducedC]
inducedC = [[minFlip(C) for C in L] for L in inducedC]
inducedC = [filterDupes(L) for L in inducedC]
flatList = [y for x in inducedC for y in x]

T3 = twoFacts(flatList,[],-1)
trips3 = getTriples(T3,[],G3.am(),-1)
toCheck3 = tripsToG(trips3,D3)
filter3 = filterIso(toCheck3)


D4 = '000123411325452463656'
D4 = decodeDirect(D4,7)
G4 = Graph(7,multiedges=True)
G4.add_edges([(0,2),(0,3),(0,4),(0,5),(0,5),(0,6),(1,3),(1,4),(1,5),(1,5),(1,6),(1,6),(2,3),(2,4),(2,4),(2,5),(2,6),(3,4),(3,5),(3,6),(4,6)])

cycles = [graphs.CycleGraph(3), graphs.CycleGraph(4), graphs.CycleGraph(5), graphs.CycleGraph(7)]
G4flat = G4.to_simple()
inducedC = [list(G4flat.subgraph_search_iterator(G,induced=False)) for G in cycles]
inducedC = [[[0,5],[1,5],[1,6],[2,4]]] + inducedC
inducedC = [[shiftToMin(C) for C in L] for L in inducedC]
inducedC = [[minFlip(C) for C in L] for L in inducedC]
inducedC = [filterDupes(L) for L in inducedC]
flatList = [y for x in inducedC for y in x]

T4 = twoFacts(flatList,[],-1)
trips4 = getTriples(T4,[],G4.am(),-1)
toCheck4 = tripsToG(trips4,D4)
filter4 = filterIso(toCheck4)


D5 = '000123311325452445666'
D5 = decodeDirect(D5,7)
G5 = Graph(7,multiedges=True)
G5.add_edges([(0,2),(0,3),(0,5),(0,5),(0,6),(0,6),(1,3),(1,3),(1,4),(1,5),(1,6),(1,6),(2,3),(2,3),(2,4),(2,4),(2,6),(3,5),(4,5),(4,5),(4,6)])

cycles = [graphs.CycleGraph(3), graphs.CycleGraph(4), graphs.CycleGraph(5), graphs.CycleGraph(7)]
G5flat = G5.to_simple()
inducedC = [list(G5flat.subgraph_search_iterator(G,induced=False)) for G in cycles]
inducedC = [[[0,5],[0,6],[1,3],[1,6],[2,3],[2,4],[4,5]]] + inducedC
inducedC = [[shiftToMin(C) for C in L] for L in inducedC]
inducedC = [[minFlip(C) for C in L] for L in inducedC]
inducedC = [filterDupes(L) for L in inducedC]
flatList = [y for x in inducedC for y in x]

T5 = twoFacts(flatList,[],-1)
trips5 = getTriples(T5,[],G5.am(),-1)
toCheck5 = tripsToG(trips5,D5)
filter5 = filterIso(toCheck5)


D6 = '000113312522446364556'
D6 = decodeDirect(D6,7)
G6 = Graph(7,multiedges=True)
G6.add_edges([(0,1),(0,2),(0,3),(0,4),(0,4),(0,5),(1,3),(1,3),(1,4),(1,5),(1,6),(2,3),(2,4),(2,5),(2,6),(2,6),(3,5),(3,6),(4,5),(4,6),(5,6)])

cycles = [graphs.CycleGraph(3), graphs.CycleGraph(4), graphs.CycleGraph(5), graphs.CycleGraph(7)]
G6flat = G6.to_simple()
inducedC = [list(G6flat.subgraph_search_iterator(G,induced=False)) for G in cycles]
inducedC = [[[0,4],[1,3],[2,6]]] + inducedC
inducedC = [[shiftToMin(C) for C in L] for L in inducedC]
inducedC = [[minFlip(C) for C in L] for L in inducedC]
inducedC = [filterDupes(L) for L in inducedC]
flatList = [y for x in inducedC for y in x]

T6 = twoFacts(flatList,[],-1)
trips6 = getTriples(T6,[],G6.am(),-1)
toCheck6 = tripsToG(trips6,D6)
filter6 = filterIso(toCheck6)


D7 = '000112312523446364556'
D7 = decodeDirect(D7,7)
G7 = Graph(7,multiedges=True)
G7.add_edges([(0,1),(0,2),(0,3),(0,4),(0,4),(0,5),(1,2),(1,3),(1,4),(1,5),(1,6),(2,3),(2,5),(2,6),(2,6),(3,4),(3,5),(3,6),(4,5),(4,6),(5,6)])

cycles = [graphs.CycleGraph(3), graphs.CycleGraph(4), graphs.CycleGraph(5), graphs.CycleGraph(7)]
G7flat = G7.to_simple()
inducedC = [list(G7flat.subgraph_search_iterator(G,induced=False)) for G in cycles]
inducedC = [[[0,4],[2,6]]] + inducedC
inducedC = [[shiftToMin(C) for C in L] for L in inducedC]
inducedC = [[minFlip(C) for C in L] for L in inducedC]
inducedC = [filterDupes(L) for L in inducedC]
flatList = [y for x in inducedC for y in x]

T7 = twoFacts(flatList,[],-1)
trips7 = getTriples(T7,[],G7.am(),-1)
toCheck7 = tripsToG(trips7,D7)
filter7 = filterIso(toCheck7)


D8 = '000124411323552346566'
D8 = decodeDirect(D8,7)
G8 = Graph(7,multiedges=True)
G8.add_edges([(0,2),(0,4),(0,5),(0,5),(0,6),(0,6),(1,3),(1,4),(1,4),(1,5),(1,5),(1,6),(2,3),(2,4),(2,4),(2,5),(2,6),(3,4),(3,5),(3,6),(3,6)])

cycles = [graphs.CycleGraph(3), graphs.CycleGraph(4), graphs.CycleGraph(5), graphs.CycleGraph(7)]
G8flat = G8.to_simple()
inducedC = [list(G8flat.subgraph_search_iterator(G,induced=False)) for G in cycles]
inducedC = [[[0,5],[0,6],[1,4],[1,5],[2,4],[3,6]]] + inducedC
inducedC = [[shiftToMin(C) for C in L] for L in inducedC]
inducedC = [[minFlip(C) for C in L] for L in inducedC]
inducedC = [filterDupes(L) for L in inducedC]
flatList = [y for x in inducedC for y in x]

T8 = twoFacts(flatList,[],-1)
trips8 = getTriples(T8,[],G8.am(),-1)
toCheck8 = tripsToG(trips8,D8)
filter8 = filterIso(toCheck8)


D9 = '000123311345442266655'
D9 = decodeDirect(D9,7)
G9 = Graph(7,multiedges=True)
G9.add_edges([(0,3),(0,4),(0,4),(0,5),(0,5),(0,6),(1,3),(1,3),(1,4),(1,5),(1,5),(1,6),(2,3),(2,3),(2,4),(2,4),(2,5),(2,6),(3,6),(4,6),(5,6)])

cycles = [graphs.CycleGraph(3), graphs.CycleGraph(4), graphs.CycleGraph(5), graphs.CycleGraph(7)]
G9flat = G9.to_simple()
inducedC = [list(G9flat.subgraph_search_iterator(G,induced=False)) for G in cycles]
inducedC = [[[0,4],[0,5],[1,3],[1,5],[2,3],[2,4]]] + inducedC
inducedC = [[shiftToMin(C) for C in L] for L in inducedC]
inducedC = [[minFlip(C) for C in L] for L in inducedC]
inducedC = [filterDupes(L) for L in inducedC]
flatList = [y for x in inducedC for y in x]

T9 = twoFacts(flatList,[],-1)
trips9 = getTriples(T9,[],G9.am(),-1)
toCheck9 = tripsToG(trips9,D9)
filter9 = filterIso(toCheck9)


#combine results and filter for isomorphism
allG = filter0+filter1+filter2+filter3+filter4+filter5+filter6+filter7+filter8+filter9
allNonIso = filterIso(allG)
print(len(allNonIso))


#print all designs
for i in range(len(allNonIso)):
    G = allNonIso[i]
    D = []
    for j in range(10,40):
        D += sorted([G.neighbors(j)])
    D = sorted(D)
    s1,s2,s3 = "","",""
    for j in range(len(D)):
        s1 += str(D[j][0])
        s2 += str(D[j][1])
        s3 += str(D[j][2])
    print(i+1,s1,s2,s3)
	