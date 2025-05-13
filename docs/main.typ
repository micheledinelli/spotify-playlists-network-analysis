#import "template.typ": *

#let inlineFrac(a, b) = { return $#super(a) #h(-1pt) slash #h(-1pt) #sub(b)$ } 

#show: project.with(
  title: "Spotify Artists Network Analysis",
  authors: (
    (name: "Massimo Rondelli", email: link("mailto:massimo.rondelli@studio.unibo.it"), affiliation: "Department of Computer Science and Engineering, University of Bologna"),
    (name: "Michele Dinelli", email: link("mailto:michele.dinelli5@studio.unibo.it"), affiliation: "Department of Computer Science and Engineering, University of Bologna"),
    (name: "Nadia Farokhpay", email: link("mailto:nadia.farokhpay@studio.unibo.it"), affiliation: "Department of Computer Science and Engineering, University of Bologna"),
    (name: "Youssef Hanna", email: link("mailto:youssefawni.hanna@studio.unibo.it"), affiliation: "Department of Computer Science and Engineering, University of Bologna"),
  ), 
)

= Introduction
Music taste is a sort of a fingerprint that identifies each of us, of course there are people who care more or less about music, but everyone must have a peculiar musical taste that is unique. People tend to group their favorite music in structures the so-called music playlist, list of songs where genres, artists and even musical periods are mixed together forming the aforementioned fingerprint, that belongs to each of us. When we thought about music playlists we realized that there must exist some sort of relationship between artists that share place inside them. This report analyzes Spotify @wiki-spotify music playlists, in particular the relationship between artists that appear in the same playlists.   

= Problem and Motivation
The rise of digital music platforms such as Spotify has impacted not only how people consume music, but also how they express their musical tastes and identity through personal playlists.  While each playlist is a unique expression, when combined, they reveal patterns. Certain artists may be more likely to appear together, implying latent associations based on genre, mood, popularity, or user behavior. Understanding these connections between artists is not a simple task.  Unlike traditional music recommendation systems that rely on metadata or user ratings, co-occurrence data implicitly embedded in playlists captures real-world, user-curated musical context. The motivation behind this analysis is to uncover the hidden structure within user-generated playlists by building and analyzing a co-occurrence network of artists.

= Dataset
The dataset used is the continuation of the RecSys Challenge 2018 @recsys-challenge-2018 and it contains 1,000,000 music playlists, created by users on the Spotify platform between January 2010 and October 2017. The dataset's original task is automatic playlist continuation: given a seed playlist title and/or an initial set of tracks in a playlist, predict the next tracks. The dataset is publicly available @dataset-source but it's not user-friendly because i) it's divided in multiple slices formatted as json files, ii) it's huge (5GB). We randomly sampled 5 dataset slices in order to drastically reduce the dimension of the upcoming network. This left us with 5000 playlists. Since we cannot (computationally) analyze such a network we computed a subgraph i) by reducing the number of playlist ii) by keeping connected components only.

The result is a monomodal, undirected and weighted co-occurrence network. Nodes represent artists, edges represent the co-occurrence of artists in the same playlist and edge weights are the product of the artists' frequencies in that playlist.

= Validity and Reliability (LOREM)
#lorem(300)

= Measures and Results
Computing network measures helps one to summarize and extract insight from complex network data in a manageable and interpretable way.  Analyzing the raw network directly is impractical due to its size and complexity. Music playlists, like many real-world networks, form intricate webs of relationships. By applying mathematical measures that capture interesting features of network structure quantitatively it's easier to extract important information such as structural roles, patterns and node importances @saverio-node-measures.

== Centrality Measures
Network centrality metrics quantify the influence or importance of a node in a network however, there is no generalized definition of centrality @South_2020, as a results many centrality measures exists @Costa_2007.

=== Degree Centrality
The most simple yet illuminating centrality metric is degree centrality. In an undirected graph it's defined by the number of edges attached to a node. Defining this in terms of the network’s adjacency matrix $W in R^(N times N)$ gives

$ c_i = sum_(j=1)^N W_(i j) $<eq:degree-centrality>

Artists with a high degree of centrality appear alongside many different artists in playlists, that means they are broadly connected across listener tastes (likely popular). Artists with a high co-occurrence rate are more likely to be frequent collaborators or playlist "glue" (these artists may be useful for playlist generation or recommendation models).

#figure(
  image("figures/degree-centrality.png", width: 80%),
  caption: [Degree centrality in the artist co-occurrence network]
)<fig:degree-centrality>

@fig:degree-centrality shows on the left the network graph where each node represents an artist and edges indicate co-occurrence in playlists. Node color is proportional to the node’s degree centrality, with brighter nodes having higher centrality. The top three most central artists are Elton John, Jason Derulo, and The Weekend. While on the right it shows distribution of degree centrality values across the network. The histogram shows a heavy-tailed distribution, indicating that while most artists have low centrality, a few act as major hubs.

=== Weighted Degree Centrality
Weighted degree centrality is an extension of degree centrality metrics that takes into account edge weights in the network, which in this analysis represent the strength of artist co-occurrence, i.e, how often  two artists appear together in playlists. In a weighted, undirected graph, weighted degree centrality measures the sum of the weights of edges incident to a node, capturing not only how many connections a node has but also how strong those connections are. Given a weighted adjacency matrix $W in R^(N times N)$, where $W_(i j)​$ denotes the weight of the edge between nodes $i$ and $j$, the weighted degree centrality $c_i(w)$​ of node $i$ is defined as

$ c_i^((w)) = sum_(j=1)^N W_(i j) $<eq:weighted-degree-centrality>

The superscript $(w)$ just indicates "weighted".

#figure(
  image("figures/weighted-degree-centrality.png", width: 80%),
  caption: [Weighted degree centrality in the artist co-occurrence network]
)<fig:weighted-degree-centrality>

@fig:weighted-degree-centrality shows on the left the network graph where nodes with higher total edge weights appear brighter. The most central artists by this metric are Drake, Travis Scott, and Future. Then @fig:weighted-degree-centrality shows on the right the histogram of weighted degree centrality values, showing a highly skewed distribution. This suggests that a few artists dominate playlist co-occurrences, likely due to frequent collaborations or broad popularity.

=== Eigenvector Centrality
Centrality can be recursively defined in terms of the centrality of a node's neighborhood. This comes from the notion that a node's importance in a network is increased by having connections to other nodes that are themselves important @South_2020. Eigenvector Centrality (eigencentrality) measure how nodes can be influential either by reaching a lot of nodes or by reaching just a few, highly-influential nodes. For this study neither eigencentrality normalization nor some tricks to avoid centrality zero-trailing problem @saverio-node-measures is applied, since the study analyzes one network only and it's undirected. 

Given a weighted adjacency matrix $A in R^(N times N)$, where $A_(i j)​$ denotes the weight of the edge between nodes $i$ and $j$ the eigenvector centrality of node $v$ is proportional to the sum of the eigenvectors centralities of $i$’s neighbors and it's defined by the following equation

$
x_v = 1/lambda sum_(j in M(v)) A_(i j) x_j
$

where $inlineFrac(1,lambda)$ is a constant and $M(v)$ is a function that returns the neighbors of the node $v$. With a small rearrangement this can be rewritten in vector notation as the eigenvector equation

$
A x = lambda x
$

In general, there will be many different eigenvalues $lambda$ for which a non-zero eigenvector solution exists. However the Perron–Frobenius theorem implies that only the greatest eigenvalue results in the desired centrality measure @saverio-node-measures @wiki-eigencentrality.

#figure(
  image("figures/eigenvector-centrality.png", width: 80%),
  caption: [Eigenvector centrality in the artist co-occurrence network]
)<fig:eqigencentrality>

On the left of @fig:eqigencentrality it's shown the network graph, where each node represents an artist and edges indicate co-occurrence in playlists. Node color is proportional to the node’s eigenvector centrality, with brighter nodes indicating higher eigencentrality. The top three most central artists by this metric are Elton John, Destiny's Child, and \*NSYNC. On the right it's shown the distribution of eigenvector centrality values across the network. The histogram reflects a skewed distribution, suggesting that only a small number of artists hold a disproportionately high level of influence within the network.

Using different centrality measure does matter. While degree centrality captures local prominence, eigenvector centrality reflects a node's position in the broader structure of the network since it considers not just the quantity but the quality of connections.

#figure(
  image("figures/top-20-degree-centrality-vs-eigencentrality.png", width: 80%),
  caption: [Top 20 artists subgraphs by degree centrality and eigencentrality]
)<fig:top-20-artists-degree-vs-eigen-centrality>

@fig:top-20-artists-degree-vs-eigen-centrality highlights the different subgraphs obtainable considering a different centrality measure. On the left it's shown the subgraph containing the 20 artists with the highest degree

=== Closeness Centrality
Closeness centrality of a node $u$ is the reciprocal of the average shortest path distance to $u$ over all $n-1$ reachable nodes @FREEMAN1978215. Closeness centrality uses the notion of mean distance between a node $u$ and other nodes in the network defined as $ell_u = 1/n sum_v d(u,v)$. Closeness centrality is basically $ell_u^(-1)$

$
C(u) = (n-1)/(sum_(v eq.not u)(d(u, v)))
$

where $d(v, u)$ is the shortest-path distance between $v "and" u$ and $n$ is the number of nodes.

#figure(
  image("figures/closeness-centrality.png", width: 80%),
  caption: [Closeness centrality in the artist co-occurrence network]
)<fig:closeness-centrality>

#figure(
  image("figures/harmonic-centrality.png", width: 80%),
  caption: [Harmonic centrality in the artist co-occurrence network]
)<fig:closeness-centrality>

=== Betweenness Centrality

#figure(
  image("figures/betweennes-centrality.png", width: 80%),
  caption: [Betweenness centrality in the artist co-occurrence network]
)<fig:closeness-centrality>

== Average Local Clustering Coefficients vs Node Degree 
The analysis of the local clustering coefficient in relation to node degree in our artist co-occurrence network reveals significant structural patterns. The graph demonstrates a clear inverse relationship between these two metrics, with clustering coefficients decreasing as node degrees increase. 
Artists with low degrees, below approximately 30 connections, exhibits clustering coefficients near 1.0, indicating that less-connected artists typically appear in playlists alongside others who are themselves interconnected. This suggests the presence of tight musical communities, likely representing specific genres or styles where artists frequently co-appear in curated playlists.

#figure(
  image("figures/average_lcc_vs_degree.png", width:  80%),
  caption: [Average Local Clustering Coefficients vs Node Degree]
)<fig:average-LCC-vs-Node-degreee>

A transition zone appears around degree 40-100, where clustering coefficients begin to decline more steeply. Artists in this range potentially function as connectors between different musical communities, maintaining some community structure while bridging across genres. wThe pronounced variability observed in the mid-range of node degrees (particularly between degrees 50-150) indicates heterogeneity among moderately popular artists. Some maintain relatively high clustering despite their popularity, possibly representing artists who achieve significant fame while remaining within particular genre boundaries, while others with similar degrees show lower clustering, suggesting broader cross-genre appeal.

= Conclusion

= Critique

#pagebreak()

#outline(title: "Figures", target: figure.where(kind: image))

// #outline(title: "Equations", target: math.equation)

#bibliography("bib.bib")

#pagebreak()

#set heading(numbering: "A.1.1", supplement: [Appendix])
#counter(heading).update(0)

= Closeness Centrality
Closeness centrality can be used to visualize the shortest path from a node $u$ to other nodes $v eq.not u$. In @fig:closeness-centrality-shortest-paths its shown the most central node by closeness centrality metric (Rihanna) and how it's connected with 3 random nodes. Intermediary nodes are highlighted in grey color.

#figure(
  image("figures/closeness-centrality-sp.png", width: 60%),
  caption: [Shortest paths from the node with highest closeness centrality degree (Rihanna) to 3 random nodes]
)<fig:closeness-centrality-shortest-paths>