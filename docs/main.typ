#import "template.typ": *
// #import "@preview/wordometer:0.1.4": word-count, total-words
// #show: word-count

#let inlineFrac(a, b) = { return $#super(a) #h(-1pt) slash #h(-1pt) #sub(b)$ } 

#show: project.with(
  title: "Network Analysis of Spotify Playlists Using Artist Co-Occurrence",
  authors: (
    (name: "Massimo Rondelli", email: link("mailto:massimo.rondelli@studio.unibo.it"), affiliation: "Department of Computer Science and Engineering, University of Bologna"),
    (name: "Michele Dinelli", email: link("mailto:michele.dinelli5@studio.unibo.it"), affiliation: "Department of Computer Science and Engineering, University of Bologna"),
    (name: "Nadia Farokhpay", email: link("mailto:nadia.farokhpay@studio.unibo.it"), affiliation: "Department of Computer Science and Engineering, University of Bologna"),
    (name: "Youssef Hanna", email: link("mailto:youssefawni.hanna@studio.unibo.it"), affiliation: "Department of Computer Science and Engineering, University of Bologna"),
  ), 
)

#let appendix(body) = {
  set heading(numbering: "A", supplement: [Appendix])
  counter(heading).update(0)
  body
}

// In this document, there are #total-words words.

= Introduction
Our individual musical tastes act as a distinctive identifier, a unique fingerprint reflecting our preferences. While the amount of engagement with music varies, everyone must have a personal musical taste that is unique. An expression of music taste is creating music playlists. These are not simply random lists of songs, they are curated collections where genres, artists, and even musical periods are often mixed, forming a reflection of an individual's unique listening habits. When we look at these playlists, it's clear that if two artists show up together a lot, there's some kind of connection, maybe their music just fits well, or fans who like one also tend to like the other. 

This report explores connections between artists on Spotify @wiki-spotify. We're specifically looking at the relationships that pop up when artists are found together in playlists made by users. By studying how often artists appear together, we can build a network of these artists. This helps us analyze how artists are linked and understand how people's music choices connect different musicians.

= Problem and Motivation

Streaming services like Spotify changed how we listen to music and show off our tastes through playlists. Even though each playlist is personal, together they reveal patterns. Artists often appear together, hinting at latent associations based on genre, mood, or how people actually use music. Unlike other recommendation methods, playlists show us how users genuinely connect artists. 

Our motivation comes from a key observation: while artists are interconnected through various means, a significant source of valuable information about these relationships is often skipped or doesn't get the attention it deserves. We're referring to the important connections established by users through their personal music playlists, they aren't analyzed nor used to extract knowledge while may represent a reflection of how listeners perceive artistic proximity @Schweiger2025. 

In @sec:dataset we describe the data source. In @sec:validity-reliability we analyze the validity and reliability of this study. In @sec:centrality-measures we analyze centrality measures to understand which are most influential nodes and understand the network structure. In @sec:power-laws, @sec:small-world, @sec:average-lccs and @sec:assortative we analyze network properties such as scale-free property and small world effect to determine node roles and network robustness. In @sec:group-of-nodes and @sec:structural-equivalence we investigate the possibility to use network analysis to build artists recommendation heuristics. In @sec:periphery we analyze network periphery. In @sec:conclusion we sum up our study with a conclusion section that recaps our findings. Finally we conclude with @sec:critique which is a critique on this study.

= Dataset <sec:dataset>
The dataset used is the continuation of the RecSys Challenge 2018 @recsys-challenge-2018 and it contains 1,000,000 music playlists, created by users on the Spotify platform between January 2010 and October 2017. The dataset's original task is automatic playlist continuation: given a seed playlist title and/or an initial set of tracks in a playlist, predict the next tracks. The dataset is publicly available @dataset-source but it's not user-friendly because it's divided into multiple slices formatted as .json files, and it's huge (5GB). We randomly sampled 10 dataset slices in order to drastically reduce the dimension of the upcoming network. This left us with 10,000 playlists. Since we cannot (computationally) analyze such a network, we computed a subgraph i by reducing the number of playlists and keeping connected components only.

The result is a monomodal, undirected and weighted co-occurrence network with 1,139 nodes and 17,908 edges. Nodes represent artists, edges represent the co-occurrence of artists in playlists and edge weights are the cumulative sum of the artists' co-occurrence frequencies (see @appendix:full-network @fig:full-network). 

= Validity and Reliability <sec:validity-reliability>
This analysis uses a publicly available dataset @recsys-challenge-2018 that is frequently employed by researchers for investigating artist relationships in user-generated playlists. It is also used in music recommendation challenges, with a total of over 15,000 users and numerous submissions from almost 300 different teams. Although only a subset of 10,000 playlists was used due to computational constraints, the random sampling strategy ensures representativeness of the larger dataset and maintains the generalizability of our findings. The entire methodology of this study is designed for transparency and reproducibility. All code and resources are open-source @github-repo, @github-page, allowing easy verification and replication of our findings. Any elements of randomness introduced are controlled through seeded generators. 

The technical implementation of the study relies on established standards de facto within the scientific community. Network analysis is performed using NetworkX @networkx. Visualizations are generated with the well-known Matplotlib and Seaborn libraries @Hunter:2007, @Waskom2021.

= Measures and Results
Computing network measures helps one to summarize and extract insight from complex network data in a manageable and interpretable way. Analyzing the raw network directly is impractical due to its size and complexity. Music playlists, like many real-world networks, form intricate webs of relationships. By applying mathematical measures that capture interesting features of network structure quantitatively, it's easier to extract important information such as structural characteristics, patterns, node importances and network properties @saverio-node-measures.

== Centrality Measures <sec:centrality-measures>
Network centrality metrics quantify the influence or importance of a node in a network; however, there is no generalized definition of centrality @South_2020, as a result, many centrality measures exist @Costa_2007.

=== Degree Centrality
Degree centrality is applied to identify artists who serve as central figures in user playlists, providing a first glimpse into influence and popularity across the network.
The simplest centrality metric is degree centrality. In an undirected graph, it's defined by the number of edges attached to a node. Defining this in terms of the network’s adjacency matrix $W in R^(N times N)$ gives the following

$ c_i = sum_(j=1)^N W_(i j) $<eq:degree-centrality>

Artists with a high degree of centrality appear alongside many different artists in playlists, which means they are broadly connected across listener tastes (likely popular). Artists with a high co-occurrence rate are more likely to be frequent collaborators or playlist "glue" (these artists may be useful for playlist generation or recommendation models).

#figure(
  image("figures/degree-centrality.png", width: 90%),
  caption: [Degree centrality in the artist co-occurrence network and degree centrality distribution]
)<fig:degree-centrality>

@fig:degree-centrality shows the network where each node represents an artist and edges indicate co-occurrence in playlists. Node color is proportional to the node’s degree centrality, with brighter nodes having higher centrality. On the right it's shown the distribution of degree centrality values across the network. As one would expect, the distribution is long-tailed, which means that only a few artists get the highest degree centrality scores hence representing popular nodes. 

=== Weighted Degree Centrality
We apply weighted degree centrality to go beyond simple connectivity and capture the strength of artist relationships in playlists, reflecting not just presence but frequency of co-occurrence. Since the network obtained is weighted, we can further analyze degree centrality using weighted degree centrality which is an extension of degree centrality that takes into account edge weights. Given a weighted adjacency matrix $W in R^(N times N)$, where $W_(i j)​$ denotes the weight of the edge between nodes $i$ and $j$, the weighted degree centrality $c_i^((w))$​ of node $i$ is defined as

$ c_i^((w)) = sum_(j=1)^N W_(i j) $<eq:weighted-degree-centrality>

#figure(
  image("figures/weighted-degree-centrality.png", width: 90%),
  caption: [Weighted degree centrality in the artist co-occurrence network and weighted degree centrality distribution]
)<fig:weighted-degree-centrality>

@fig:weighted-degree-centrality shows the network, where nodes with higher centrality appear brighter. On the right it's shown the distribution of weighted degree centrality, showing again a highly skewed (right) distribution. This suggests that a few artists dominate playlist co-occurrences, likely due to frequent collaborations or broad popularity.

=== Eigenvector Centrality
Unlike simpler metrics that count direct links, eigenvector centrality captures influence through association with other important nodes @South_2020. An artist may be central not by reaching many others, but by connecting to a few highly influential ones. This recursive definition emphasizes quality over quantity of connections. In our case, since the network is undirected and analyzed as a single component, we don’t apply normalization or zero-trailing adjustments @saverio-node-measures.

Given a weighted adjacency matrix $A in R^(N times N)$, where $A_(i j)​$ denotes the weight of the edge between nodes $i$ and $j$ the eigenvector centrality of node $v$ is proportional to the sum of the eigenvectors centralities of $i$’s neighbors and it's defined by the following equation

$
x_v = 1/lambda sum_(j in M(v)) A_(i j) x_j
$

where $inlineFrac(1,lambda)$ is a constant and $M(v)$ is a function that returns the neighbors of the node $v$. With a small rearrangement, this can be rewritten in vector notation as the eigenvector equation

$
A x = lambda x
$

In general, there will be many different eigenvalues $lambda$ for which a non-zero eigenvector solution exists. However, the Perron–Frobenius theorem implies that only the greatest eigenvalue results in the desired centrality measure @saverio-node-measures @wiki-eigencentrality.

#figure(
  image("figures/eigenvector-centrality.png", width: 90%),
  caption: [Eigenvector centrality in the artist co-occurrence network]
)<fig:eqigencentrality>

// @fig:eqigencentrality shows eigencentrality values in the network. Node color is proportional to the node’s eigenvector centrality, with brighter nodes indicating higher eigencentrality. On the right it's shown the distribution of eigenvector centrality. The histogram reflects (again) a skewed right distribution, suggesting that only a small number of artists hold a disproportionately high level of influence within the network. 

// These metrics seem redundant, but using different centrality measures does matter. While degree centrality captures local prominence, eigenvector centrality reflects a node's position in the broader structure of the network since it considers not just the quantity but the quality of connections.

@fig:eqigencentrality shows eigencentrality across the network, with brighter nodes indicating higher values. The histogram on the right is right-skewed, suggesting that a few artists hold most of level of influence within the network. 

These metrics seem redundant but eigencentrality captures broader structural importance by factoring in the influence of a node’s neighbors, not just how many they are, but how connected they are.

#figure(
  image("figures/top-30-eigen-vs-degree-centrality.png", width: 90%),
  caption: [Top 30 artists subgraphs by degree centrality and eigencentrality]
)<fig:top-30-artists-degree-vs-eigen-centrality>

// @fig:top-30-artists-degree-vs-eigen-centrality highlights the different subgraphs obtainable considering a different centrality measure. On the left it's shown the subgraph containing the 30 artists with the highest degree centrality, while on the right it's shown the subgraph containing the 30 artists with the highest eigencentrality. It's clear that the two networks are very different. The one representing the highest degree centrality is less connected, while the one representing eigencentrality clearly shows higher density (0.6759 vs 0.9977). The average degree of the one representing degree centrality is 19.60, while the one representing the eigencentrality is 28.93. This contrast shows how local versus global centrality measures emphasize different structural roles @PhysRevE.

@fig:top-30-artists-degree-vs-eigen-centrality compares subgraphs based on different centrality measures. The left shows the top 30 by degree centrality; the right, by eigencentrality. It's clear that the two are structurally distinct: the degree-based subgraph is less connected, with lower density (0.6759 vs 0.9977) and average degree (19.60 vs 28.93). This shows how local and global centrality capture different structural roles @PhysRevE.

=== Closeness Centrality <sec:closeness-centrality>
In collaborative playlists, some artists naturally emerge as intermediaries, linking otherwise separate listening communities. Betweenness centrality helps uncover these bridges. Closeness centrality of a node $u$ is the reciprocal of the average shortest path distance to $u$ over all $n-1$ reachable nodes @FREEMAN1978215. Closeness centrality uses the notion of mean distance between a node $u$ and other nodes in the network defined as $ell_u = 1/n sum_v d(u,v)$. Closeness centrality is basically $ell_u^(-1)$

$
C(u) = (n-1)/(sum_(v eq.not u)(d(u, v)))
$

where $d(v, u)$ is the shortest-path distance between $v "and" u$ and $n$ is the number of nodes.

#figure(
  image("figures/closeness-centrality.png"),
  caption: [Closeness centrality in the artist co-occurrence network]
)<fig:closeness-centrality>

@fig:closeness-centrality shows the closeness centrality metric applied to the network. Node color is proportional to closeness centrality with brighter colors indicating higher centrality. The histogram on the right shows the closeness centrality distribution, which appears approximately normal. This is because the values of the mean distance typically have a small range, as they are limited by the diameter of the network, which is typically between 1 and $log n$. Our network has a diameter of 7 and 1139 nodes, so bingo because $log(1139) tilde.eq 7$.

// Closeness centrality may fail in disconnected networks because distances between components are infinite @saverio-node-measures since it assumes full reachability. Fortunately, the network is connected, so we don't need to investigate alternative metrics such as harmonic centrality.

Since closeness assumes full reachability, it fails in disconnected graphs @saverio-node-measures. But here, the network is connected, so no alternative like harmonic centrality is needed.

=== Betweenness Centrality
// In a co-occurrence network of artists, some nodes play a key role in connecting otherwise distant clusters — betweenness centrality reveals these influential bridges. Betweenness centrality measures how often a node lies on the shortest paths between other nodes, reflecting its role as a bridge or gateway in the network. It is calculated by summing, for all node pairs, the fraction of shortest paths between them that pass through the node of interest. Mathematically, the betweenness centrality of node $n in N$, where $N$ is the set of all nodes in the network, can be expressed as follows: 

In a co-occurrence network of artists, some nodes act as key bridges between distant clusters, betweenness centrality helps identify these connectors. It measures how often a node lies on the shortest paths between all other nodes, highlighting its role in linking the network. Formally, for a node $n in N$, where $N$ is the set of all nodes, betweenness centrality is defined as:

$
C_(B)(n) = sum_(s eq.not n eq.not d) (sigma_(s d)(n))/sigma_(s d)
$

where $sigma_(s d)$ is the total number of paths between $s$ and $d$ and $sigma_(s_d)(n)$ is the number of paths between the pair that pass through node $n$. 

This captures how much "traffic" a node handles. To account for multiple shortest paths and make values comparable, betweenness is often normalized by dividing by the total number of possible node pairs, scaling the measure between 0 and 1.

$
C_B^("norm")(n) = 1/inlineFrac(n^2, 2) sum_(s eq.not n eq.not d) (sigma_(s d)(n))/sigma_(s d)
$

#figure(
  image("figures/betweennes-centrality.png"),
  caption: [Betweenness centrality in the artist co-occurrence network]
)<fig:betweenness-centrality>

@fig:betweenness-centrality shows the betweenness centrality metric applied to the network. Node color is proportional to betweenness centrality with brighter colors indicating higher centrality. On the right there is the distribution of betweenness centrality that appears highly skewed on the right. This means that only a small number of nodes act as "gateways" gluing different parts of the networks together.

== Power Laws and Scale-free Networks <sec:power-laws>
Understanding whether artist centrality follows a power-law helps assess the network’s robustness and the concentration of influence, both key to analyzing real-world musical ecosystems. Networks whose degree distribution follows a power-law are known as scale-free networks. These networks are notably resilient, able to maintain overall connectivity even when a significant number of nodes fail @saverio-network-measures. To detect power-law behavior, one can use the cumulative distribution function (CDF), which gives the probability that a node has degree $gt.eq d$

$
P_d = sum_(d' eq.not d)^infinity p_(d^('))
$

If the degree distribution follows a power-law, it can be described in logarithmic form as

$
p_d = -alpha ln(d) + c
$<eq:power-law-1>

which simplifies to

$
p_d = C d^(-alpha)
$

where $C = e^c$ is a normalization constant and $alpha$ is the power-law exponent. To quantitatively assess the power-law fit, $alpha$ can be estimated using

$
alpha = 1 + n (sum_i ln d_i/(d_min - 1/2))^(-1)
$

Empirically, power-law distributions in networks typically fall within the range $2 lt.eq alpha lt.eq 3$.

#figure(
  image("figures/power-law.png", width: 90%),
  caption: [Power Law fit of weighted centrality, closeness centrality, betweenness centrality and eigencentrality in the artist co-occurence network]
)<fig:power-law>

// In @fig:power-law we show the power-law fit of 4 centrality measures distributions we analyzed in @sec:centrality-measures namely weighted centrality, closeness centrality, betweenness centrality and eigencentrality. On the y-axis lies the CDF of the metric, while on the x-axis the metric values (both in logarithmic scale). All of them reflects a scale-free structure except for closeness centrality, which is expected since as mentioned in @sec:closeness-centrality the values of the mean distance are limited by the diameter of the network @Evans_2022.

@fig:power-law shows the power-law fit for four centrality measures from @sec:centrality-measures: weighted, closeness, betweenness, and eigenvector centrality. The plots display CDF vs. metric values on a log-log scale. All follow a scale-free pattern, except closeness centrality, which is actually expected, as its values are limited by network diameter @Evans_2022 (see @sec:closeness-centrality).

== Small World Effect <sec:small-world>
A small-world network is a graph characterized by a high clustering coefficient (0.527 in our network) and low distances on average (3.026). In an example of the social network, high clustering implies the high probability that two friends of one person are friends themselves @wiki-small-world. Networks show small-world effects when

$
ell prop log n
$

where $ell$ is the mean distance of the whole network represented by

$ ell = (sum_(i j) d_(i j))/n^2 $

and $d_(i j)$ is the shortest path between node $i "and" j$.

#figure(
  image("figures/small-world.png", width: 60%),
  caption: [Small World Effect]
)

We can safely say that the network we're considering is a "small world" since $ell = 3.02649$ and $log n = 7.04$ @github-repo. Nirvana acts as a mediator between Michael Jackson and Rihanna.

#figure(
  image("figures/average-sp-length.png", width: 60%),
  caption: [Network Resilience: Average Shortest Path Length vs Iterative Node Removal]
)<fig:average-sp-length>

Since a network that show small world effect is generally robust to random permutations we tested iterative node removal against the average shortest path length $ell$. In @fig:average-sp-length we show that this intuition is true since there is no linear nor polynomial/exponential relationship between the two axes. The $ell$ variation is really small. 

We  formalize small world-ness results using random graph theory thus calculating $omega$ defined as

$
omega = L_r/L - C/C_l
$

where $L_r/L$ is the ratio between the average shortest path of the Erdös–Rényi random graph with the same size the network and the average shortest path of the network and $C/C_l$ is the ratio between the average clustering coefficient of the network and the average clustering coefficient of a regular network of the same size. The network shows $omega=-0.2904$ @github-repo. Graph used are showed in @appendix:small-world @fig:random-regular-networks.

== Average Local Clustering Coefficients vs Node Degree <sec:average-lccs>
While node degree is a notion already introduced in @sec:centrality-measures, Local Clustering Coefficients (LCCs) of a node $i$ is calculated, by examining all distinct pairs of its neighbors. We count how many of these pairs are directly connected to each other and divide that by the total number of possible neighbor pairs. If the degree of node $i$ is $k_i$​, then the number of possible pairs is given by the binomial coefficient $binom(k_i, 2)$. The coefficient thus represents the likelihood that two neighbors of a node are also neighbors themselves.

#figure(
  image("figures/average_lcc_vs_degree.png", width: 90%),
  caption: [Average Local Clustering Coefficients vs Node Degree]
)<fig:average-LCC-vs-Node-degreee>

// In the context of the Spotify playlists, the clustering coefficient-degree relationship reveals how artists organize with the musical industry. Looking at the @fig:average-LCC-vs-Node-degreee a trend can be seen: as the node degree increases, there is a decrease in the average LCC. Through that, we can make some consideration regarding the musical ecosystem. Artists with a low degree and a high clustering can be thought as niche artists. They have few collaborators but strong connections among those. Viceversa, artists with high degree and low clustering can be considered as popular artists in the network. They appear across diverse playlists and connect different musical styles. 

In Spotify playlists, the clustering coefficient-degree relationship reveals how artists are positioned in the musical ecosystem. As shown in @fig:average-LCC-vs-Node-degreee, average clustering tends to decrease as degree increases.

Artists with low degrees and high clustering are often niche, they have few but tightly connected collaborators. In contrast, high-degree artists with low clustering are typically popular figures who span across diverse playlists and link different musical styles.

== Groups of Nodes <sec:group-of-nodes>
In network analysis, groups of nodes are subsets of nodes that are more densely connected to each other than to the rest of the network. Structures such as cliques, k-cores and k-components help reveal hidden patterns and relationships. Considering artist co-occurrence network, they can uncover musical communities based on shared audience preferences or stylistic similarity.

=== Clique Analysis
A clique is a group of artists who all appear together in at least one playlist, meaning every artist in the group is directly connected to every other artist based on shared playlist presence. We identified 3,043 maximal cliques with an average size of $tilde$ 12 artists.

#figure(
  image("figures/combined_clique_analysis.png", width: 90%),
  caption: [Combined clique analysis with distribution of clique sizes and artist frequencies in cliques]
)<fig:combined_clique_analysis>

// The distribution of clique sizes, as shown in the left panel of @fig:combined_clique_analysis, ranges from 2 to 54 artists, with the highest concentration around cliques of 10-14 artists. The top 20 artists by clique participation are displayed in the right panel of @fig:combined_clique_analysis. Drake (1,971), Chris Brown (1,314) and Rihanna (1,298) are the top artists by clique participation demonstrating their versatility and cross-genre appeal.

The left panel of @fig:combined_clique_analysis shows clique sizes ranging from 2 to 54, with most between 10–14 artists. The right panel lists the top 20 artists by clique participatio, Drake (1,971), Chris Brown (1,314), and Rihanna (1,298) lead, highlighting their versatility and cross-genre appeal.

We show the three largest cliques to examine the structure of the most significant artist communities.

#figure(
image("figures/cliques.png"),
caption: [Visualization of the three largest clique containing 54, 50 and 49 artists respectively. Edge thickness represents the strength of co-occurrence relationships.]
)<fig:cliques>

In @fig:cliques the left panel shows the largest clique of 54 artists in a fully connected subgraph. This massive community can represent either artists from related genres (in this case predominantly rock and punk). As shown in @fig:cliques center and right panel, rap and hip-hop are the predominant genres. The clique analysis captures audience-driven associations in artist groupings, revealing how listeners and curators organize music on Spotify.
While many groups are genre-based, others may form around shared moods, cultural trends or recommendation algorithms, reflecting the complex nature of music consumption. Clique analysis offers a valuable approach for enhancing artist recommendations. For example if a user's playlist contains multiple artists that form a clique within our network, it strongly suggests a cohesive musical taste. In such cases, we can confidently recommend other artists belonging to the same clique who are not yet present in the user's playlist.

=== K-Cores
// The k-core is a flexible grouping notion in network analysis. Unlike a clique where each node connects to all others, a k-core is a connected set of nodes where each connects to at least k others in the set,  they are useful because they are relatively easy to identify.
// In our analysis, this approach provides valuable insights for developing recommendation heuristics. Even if there aren't any direct connections between the artists in a K-core, their common presence suggests an intrinsic underlying affinity. This allows us to identify indirect paths for recommendations: if two artists, A and B, are in the same K-core but lack a direct link, the artists they do share in common (their neighbors within the K-core) can serve as bridges to suggest artist B to a listener of artist A. This strategy is particularly effective for revealing highly compatible artists even without direct co-occurrence, as well as highlighting the most important nodes for network connectivity.

The K-core is a flexible way to group nodes: each node is connected to at least K others in the set, unlike cliques which require full connectivity. It's easy to compute and useful for uncovering structure. In our case, K-cores help build recommendation heuristics. Even without direct links, artists in the same K-core often share an underlying affinity. If artist A and B share neighbors within a K-core, they can be recommended to each other’s listeners. This approach highlights strong indirect connections and key nodes that support network cohesion.

Our analysis found a maximum core number of 53, with 54 nodes (4.74% of network) in the maximum K-core, and an average core number of 22.12.

#figure(
image("figures/k-core.png", width: 90%),
caption: [Visualization of the maximum K-core and core distribution across the network]
)<fig:k-core>

// Identifying artists in the maximum K-core (53-core) reveals a highly cohesive group where each connects to at least 53 others. They are perfect candidates for the previously indicated recommendation heuristics because of their high internal connection, and crucially, signifies their high impact on network connectivity and robustness.  

// To better understand the hierarchical structure of the network, we visualized several K-cores at different K values.

// The visualization below illustrates the "onion-like" decomposition of our artist network, revealing its intrinsic core-periphery structure. This incremental layering, where each K-core represents a distinct layer, highlights increasingly coherent groups and demonstrates how core numbers function as a centrality indicator. The 1-core, representing the entire connected network, includes 1,139 nodes and 17,908 edges (the full network). Moving inwards, the 15-core contains 788 nodes and 15,766 edges, while the 30-core further condenses to 280 nodes and 7,177 edges. Finally, the innermost and densest layer is the 53-core, our maximum K-core, composed of  54 highly interconnected nodes and 1,431 edges. This highlights a robust central community of artists within the broader network.

The 53-core reveals a highly cohesive group where each artist connects to at least 53 others. These artists play a crucial role in holding the network together and are ideal candidates for recommendation heuristics due to their strong internal links and influence on connectivity and robustness.

To better understand this structure, in @fig:multiple_k_cores we visualized several K-cores, uncovering an "onion-like" layering that reflects the network’s core-periphery organization. The outer 1-core includes the entire network (1,139 nodes), while the 15-core narrows to 788 nodes, and the 30-core to 280. At the center lies the 53-core, just 54 densely connected artists with 1,431 edges, spotting the most tightly knit and influential part of the network. A well-connected network is revealed by K-core analysis, and this organized decomposition serves as a basis for network-based recommendation algorithms, greatly improving the discovery of music.

#figure(
image("figures/multiple_k_cores.png", width: 90%),
caption: [Visualization of several K-cores at different K values]
)<fig:multiple_k_cores>

// === K-Components

// === K-Shell Decomposition

== Periphery Structure <sec:periphery>

// We measured the periphery nodes in order to have a better understanding of the network's topology.  These nodes are situated at the network's topological boundary since they have the shortest path length, which makes them the most distant from every other node.

// We identified 10 such periphery nodes in the graph. These nodes have a relatively low degree, suggesting that they have few direct connections to other artists. The degree distribution contrast in @fig:periphery makes this very evident. The whole network (in blue) has a long-tailed distribution that is in line with social and musical graphs found in the real world, whereas the periphery nodes (in red) create a steep, narrow peak close to the low-degree region.

// We looked at these periphery nodes' community affiliation in addition to their structural characterization. Interestingly, 9 of them belong to Community 3, which clusters around worship and Christian music artists such as Phil Wickham, All Sons & Daughters, and Matt Gilman. The final periphery node, Wim Kijne, resides in Community 6, a smaller and more fragmented component of the network. This analysis suggests that genre-specific subcultures, particularly those less represented in mainstream playlists, tend to form the structural boundaries of the network.

// We measured the periphery nodes to better understand the network's topology. These nodes lie at the outer edges of the network, defined by having the longest shortest path distances from all other nodes; in other words, they are the most distant.

// We identified 10 such nodes in the graph. These artists have relatively low degree centrality, indicating few direct co-occurrences with others. This is reflected in the degree distribution shown in @fig:periphery: the entire network (in blue) follows a typical long-tailed distribution, while the periphery nodes (in red) form a narrow, steep peak in the low-degree range.

// We also examined the community affiliations of these peripheral nodes. Notably, 9 of them belong to Community 3, which centers around worship and Christian music artists such as Phil Wickham, All Sons & Daughters, and Matt Gilman. The remaining node, Wim Kijne, is part of Community 6, a smaller, more fragmented subnetwork. This indicates that genre-specific and less mainstream subcultures often occupy the structural periphery of the artist network @fig:periphery.

// By identifying artists who are a part of the network but are not deeply embedded in its core dynamics, this statistic provides helpful insight into the network's structural margins. Their position indicates genre-specific isolation, low collaborative integration, or limited exposure. 

We measured the periphery nodes to better understand the network's structure. These are the most distant nodes, with the longest shortest paths to others, typically sitting at the outer edges. We found 10 such artists, all with low degree centrality, few direct co-occurrences. As shown in @fig:periphery, they form a sharp peak in the low-degree region, contrasting with the network’s broader long-tailed distribution. Most of these artists (9 out of 10) belong to Community 3, focused on worship and Christian music, while the remaining one, Wim Kijne, belongs to the smaller, fragmented Community 6. This suggests that niche or less mainstream genres often populate the structural boundaries of the network.

These nodes offer insight into the network's outer margins, highlighting artists with limited exposure, fewer collaborations, and genre-specific isolation.

#figure(
  image("figures/periphery.png", width: 90%),
  caption: [Periphery highlights and degree centrality distribution of periphery nodes vs all nodes]
)<fig:periphery>

== Structural Equivalence <sec:structural-equivalence>
We introduce structure equivalence analysis to focus on node similarity and apply different measures to understand how it's possible to determine
Structural equivalence is a count of the number of common neighbors two nodes have, mathematically

$
n_(i j) = sum_k A_(i k) A_(k j)
$

Since low-degree nodes are penalized we introduce cosine similarity, defined as

$
"cs"_(i j) = n_(i j) / sqrt(d_i d_j)
$

where $n_(i j)$ is the number of common neighbors between node $i$ and node $j$, and $sqrt(d_i d_j)$ is the geometric mean of degrees.

Two alternatives to cosine similarity are Jaccard similarity defined as the number of
common neighbors divided by the total number of distinct neighbors of both
nodes, namely

$
J_(i j) = n_(i j) / (d_i + d_j - n_(i j))
$

and Pearson Correlation

$
r_(i j) = (sum_(k) ((A_(i k) - angle.l A_i angle.r) ) sum_(k) ((A_(j k) - angle.l A_j angle.r) ))/(sum_(k) (sqrt(A_(i k) - angle.l A_i angle.r)^2 ) sum_(k) (sqrt(A_(j k) - angle.l A_j angle.r)^2 ))
$

where $angle.l A_i angle.r$ is the average of the i-th row and of course $angle.l A_j angle.r$ of the j-th.

// In @fig:equivalence and @fig:equivalence-top, we compare the four structural equivalence metrics introduced earlier across two groups of nodes: 25 randomly selected nodes and the top 25 nodes ranked by degree centrality. On top left there is common neighbors normalized, on top right cosine similarity, on lower left Jaccard similarity and on lower right Pearson correlation. The results reveal notable differences between the structural equivalence metrics, highlighting that each of them captures distinct aspects of node similarity. Specifically, a high number of shared neighbors does not necessarily correspond to high cosine or Jaccard similarity, as these metrics include normalization that adjusts for node degree.
// The main differences between @fig:equivalence and @fig:equivalence-top suggest that nodes with high degree centrality generally show greater structural similarity than randomly selected nodes. 

@fig:equivalence and @fig:equivalence-top compare four structural equivalence metrics across two node groups: 25 random nodes and the top 25 by degree centrality. The charts show normalized common neighbors (top left), cosine similarity (top right), Jaccard (bottom left), and Pearson correlation (bottom right).

The results highlight how each metric captures different aspects of similarity. High shared neighbors don’t always mean high cosine or Jaccard scores, due to normalization. Overall, high-degree nodes tend to show stronger structural similarity than random ones.


#figure(
  image("figures/equivalence.png"),
  caption: [Structural equivalence metrics applied to 25 random nodes from the network]
)<fig:equivalence>

// This pattern likely comes from the fact that high-centrality nodes have more connections, increasing the likelihood of shared neighbors and stronger pairwise similarity. While the use of co-occurrence as the basis for constructing such a network may have limitations, it largely explains the observed trends in similarity.

// Structural equivalence analysis was performed to better understand the roles and similarities of nodes within the network. Nodes with high structural equivalence often share similar functions or positions, even if they are not directly connected. A really important role of this analysis is that it also provides insights into the structure of the network and can be useful for predicting future links. For example, if two nodes have high structural equivalence, meaning they are connected to many of the same nodes, they can be considered similar in terms of their role in the network. This makes them good candidates for mutual recommendation. In the case of music playlists, artists with similar connection patterns may appeal to the same listeners, even if they are not directly related, and can therefore be recommended to users based on shared network structure. Based on structural analysis only, we can safely say that some artists may be good candidates for mutual recommendation. Their similar network positions suggest they may appeal to the same listeners (see @fig:equivalence-top).

This pattern likely results from high-centrality nodes having more connections, which increases the chances of shared neighbors and stronger similarity scores. While using co-occurrence has its limitations, it still helps explain the observed trends.

Structural equivalence analysis offers insight into node roles and similarities, even without direct connections. Nodes with high structural equivalence often share network positions, making them suitable for predicting future links or recommendations. In music playlists, artists with similar connection patterns may appeal to the same listeners. Based on structural analysis only, we can safely say that some artists may be good candidates for mutual recommendation since their similar network positions suggest they may appeal to the same listeners (see @fig:equivalence-top).

#figure(
  image("figures/equivalence-top-25.png"),
  caption: [Structural equivalence metrics applied to top 25 artists by degree]
)<fig:equivalence-top>

== Homophily and Assortative Mixing <sec:assortative>
A network is assortative if a significant fraction of the edges in the network run between nodes of the same type. We investigate a particular case of assortative mixing which is assortative mixing by degree. We want to understand if high-degree nodes tend to stick together, meaning that popular artists actually saturate playlists.

#figure(
  image("figures/assortativity.png", width: 90%),
  caption: [Homophily and assortative mixing by degree]
)<fig:assortativity>

// Mixing by degree is an interesting example of assortative mixing based on a scalar parameter. In a network with assortative mixing by degree, high-degree nodes preferentially connect to other high-degree nodes, while low-degree nodes connect to lower-degree nodes. A strong diagonal in the heat-map of @fig:assortativity means assortative mixing (nodes connect to others of similar degree). The network is not completely assortative network, but still for lower node degrees, it shows an assortative property. This is interesting because one should expect exactly the opposite, but this is probably due to the fact of degree distribution, which has its peak for lower degree nodes.

Mixing by degree shows whether nodes tend to connect to others with similar degrees. In @fig:assortativity, the strong diagonal indicates assortative mixing—especially among lower-degree nodes. While the network isn’t fully assortative, this pattern stands out, likely due to the degree distribution peaking at lower values. Interestingly, this goes against the typical expectation of disassortative behavior in similar networks.


= Conclusion <sec:conclusion>
This study examined an artist co-occurrence network, built from Spotify playlist data @dataset-source, revealing important insights into user musical tastes and the network's structure. The network, containing 1,139 artists and 17,908 connections, showed features common in real-world social systems. These included a scale-free pattern, meaning some artists had many more connections than others, and a 'small-world' effect, where any two artists could be linked by a few steps. Looking at how central each artist was, we found that a small number had much more influence, often acting as key connectors between different parts of the network. K-core decomposition further revealed a layered structure, like an onion, with a tightly connected core group of artists essential for the network's strength. Finding tightly connected groups of artists (cliques) also gave us a direct way to suggest new artists based on what users already like. Conversely, artists at the network's edge were often part of specific, smaller music groups or styles.

Taken together, these findings provide a good starting point for building more effective music recommendation systems. The network's demonstrated small-world property and scale-free nature confirming its applicability for real-world recommendations. Specifically, the identification of cliques allows for direct recommendations within established taste groups, suggesting artists who are closely associated but not yet in a user's playlist. Also, K-core analysis helps determining coherent communities of artists, enabling recommendations that either deepen a user's core taste or expand it within a well-defined musical group of artists. In addition, the analysis of structural equivalence revealed that patterns based on the similarity of network positions may be used to develop heuristics for music recommendation. This suggests it may be possible to identify new recommendation strategies solely through examining the structure of the artist co-occurrence network. Finally, artists exhibiting high betweenness centrality emerge as prime candidates for recommendations aimed at bridging different musical tastes. These "bridge" artists connect distinct groups, making them ideal for introducing users to new but related sounds, thus expanding exploration beyond their current favorite artists.

= Critique <sec:critique>
This analysis is limited by the fact that we are working with a very small subset of the original dataset. The full dataset contains one million playlists, but due to computational constraints, we randomly sampled only 10 slices @dataset-source, resulting in 10,000 playlists. This reduced scale may not fully capture the diversity and complexity of user-generated content on the Spotify platform. However, the sampling was performed randomly to preserve general representativeness within practical limits.
The difficulty of interpreting co-occurrence relationships has an impact on the entire study. Co-occurrence does not imply a significant or deliberate relationship between artists, even though it may imply similarities, such as similar genres or degrees of popularity. In addition, playlists created by users are arbitrary and might not always correspond with official music classification. As a result, even though the network structure shows intriguing patterns, inferences from it should be considered exploratory rather than final.

// This analysis is based on a small, randomly sampled subset of the full dataset, consisting of 10,000 playlists out of one million available @dataset-source. While the reduced scale was necessary for computational reasons, the random sampling helps maintain general representativeness.

// It's important to note that co-occurrence in playlists does not necessarily reflect a deliberate or meaningful relationship between artists. Such patterns may be influenced by factors like genre similarity or popularity rather than intentional grouping. Moreover, user-created playlists do not always align with formal music classifications. Therefore, findings based on the network structure should be viewed as exploratory @dataset-source.

#pagebreak()

// #outline(title: "Figures", target: figure.where(kind: image))

// #outline(title: "Equations", target: math.equation)

#bibliography("bib.bib")

#pagebreak()

#show: appendix

= Full Network <appendix:full-network>

#figure(
  image("figures/full-network.png"),
  caption: [On the right the full network representation. On the left a random subset of nodes to demonstrate what the network looks like. The more darker and thicker the edges, the higher the co-occurrence between nodes.]
)<fig:full-network>

= Centrality
Closeness centrality can be used to visualize the shortest path from a node $u$ to other nodes $v eq.not u$. In @fig:closeness-centrality-shortest-paths its shown the most central node by closeness centrality metric (Drake) and how it's connected with 3 random nodes. Intermediary nodes are highlighted in grey color.

#figure(
  image("figures/closeness-centrality-sp.png", width: 60%),
  caption: [Shortest paths from the node with highest closeness centrality degree (Drake) to 3 random nodes]
)<fig:closeness-centrality-shortest-paths>

An example of what happens when removing nodes with high betweenness centrality values is shown in @fig:betweenness-centrality-removal where the top 50 nodes are removed from the network. This results in a less connected network with 14 components.

#figure(
  image("figures/betwenness-centrality-removal.png"),
  caption: [Removal of top nodes by betweennes centrality]
)<fig:betweenness-centrality-removal>

= Small World Effect<appendix:small-world>

#figure(
  image("figures/random-regular-networks.png"),
  caption: [Erdös–Rényi random graph and a regular Graph]
)<fig:random-regular-networks>

The Erdös–Rényi random graph and a regular graph used to calculate $omega$.
Regular graph is generated using `nx.watts_strogatz_graph(n=n, k=k, p=0)`. When the rewiring probability p is set to 0, the Watts-Strogatz model generates a k-regular ring lattice. This means every node in the graph has the same degree, making it a regular graph.