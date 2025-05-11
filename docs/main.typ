#import "template.typ": *

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

= Validity and Reliability (lorem)
#lorem(300)

= Measures and Results
Computing network measures helps one to summarize and extract insight from complex network data in a manageable and interpretable way.  Analyzing the raw network directly is impractical due to its size and complexity. Music playlists, like many real-world networks, form intricate webs of relationships. By applying mathematical measures that capture interesting features of network structure quantitatively it's easier to extract important information such as structural roles, patterns and node importances @saverio-node-measures.

== Centrality Measures
Network centrality metrics quantify the influence or importance of a node in a network however, there is no generalized definition of centrality @South_2020, as a results many centrality measures exists @Costa_2007.

=== Degree Centrality
The most simple yet illuminating centrality metric is degree centrality. In an undirected graph it's defined by the number of edges attached to a node. Defining this in terms of the network’s adjacency matrix $A$ with $N$ nodes gives

$ c_i = sum_(j=1)^N A_(i j) $

Artists with a high degree of centrality appear alongside many different artists in playlists, that means they are broadly connected across listener tastes (likely popular). Artists with a high co-occurrence rate are more likely to be frequent collaborators or playlist "glue" (these artists may be useful for playlist generation or recommendation models).

#figure(
  image("figures/degree-centrality.png", width: 75%),
  caption: [Visualization of degree centrality in the artist co-occurrence network. On the left: network graph where each node represents an artist and edges indicate co-occurrence in playlists. Node color and size are proportional to the node’s degree centrality, with brighter and larger nodes having higher centrality. The top three most central artists are Elton John, Jason Derulo, and The Weekend. On the right: distribution of degree centrality values across the network. The histogram shows a heavy-tailed distribution, indicating that while most artists have low centrality, a few act as major hubs.]
)

== Weighted Degree Centrality
Weighted degree centrality is an extension of degree centrality metrics that takes into account edge weights in the network, which in this analysis represent the strength of artist co-occurrence, i.e, how often  two artists appear together in playlists. In a weighted, undirected graph, weighted degree centrality measures the sum of the weights of edges incident to a node, capturing not only how many connections a node has but also how strong those connections are. Given a weighted adjacency matrix $W in R^(N times N)$, where $W_(i j)​$ denotes the weight of the edge between nodes $i$ and $j$, the weighted degree centrality $c_i(w)$​ of node $i$ is defined as:

$ c_i^((w)) = sum_(j=1)^N W_(i j) $

The superscript $(w)$ just indicates "weighted".

#figure(
  image("figures/weighted-degree-centrality.png", width: 75%),
  caption: [Visualization of weighted degree centrality in the artist co-occurrence network. On the left: network graph where node size and color represent the weighted degree centrality, accounting for the frequency of artist co-occurrence. Nodes with higher total edge weights appear larger and brighter. The most central artists by this metric are Drake, Travis Scott, and Ed Sheeran. On the right: histogram of weighted degree centrality values, showing a highly skewed distribution. This suggests that a few artists dominate playlist co-occurrences, likely due to frequent collaborations or broad popularity.]
)

=== Eigencentrality
Centrality can be recursively defined in terms of the centrality of a node's neighbourhood. This comes from the notion that a node's importance in a network is increased by having connections to other nodes that are themselves important.

= Conclusion

= Critique

#pagebreak()

#outline(title: "Figures", target: figure.where(kind: image))

#bibliography("bib.bib")
