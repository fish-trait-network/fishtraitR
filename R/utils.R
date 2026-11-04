
node_to_tip_dist <- function(phy, node) {
  if(is.character(node)){
    node = match( node, c(phy$tip.label, c(phy$node.label)) )
  }

  Nt   <- Ntip(phy)
  Nn   <- Nt + phy$Nnode
  anc  <- phy$edge[, 1]
  desc <- phy$edge[, 2]
  el   <- phy$edge.length

  # Put edges in an order where parents are processed before children
  phy <- reorder(phy, "cladewise")
  anc <- phy$edge[, 1]; desc <- phy$edge[, 2]; el <- phy$edge.length

  parent  <- integer(Nn);  parent[desc] <- anc
  elen_up <- numeric(Nn);  elen_up[desc] <- el      # length of edge above each node

  # Mark the path from `node` up to the root
  on_path <- logical(Nn)
  path_dist <- numeric(Nn)                          # distance from `node` to each ancestor
  x <- node
  d <- 0
  on_path[x] <- TRUE
  while (parent[x] != 0L) {
    d <- d + elen_up[x]
    x <- parent[x]
    on_path[x] <- TRUE
    path_dist[x] <- d
  }

  # Distance from `node` to every node:
  #  - ancestors: path_dist
  #  - others: distance to nearest on-path ancestor (via preorder sweep) + path_dist of that ancestor
  dist <- numeric(Nn)
  dist[on_path] <- path_dist[on_path]
  for (i in seq_along(desc)) {                      # cladewise = parents before children
    ch <- desc[i]
    if (!on_path[ch]) dist[ch] <- dist[anc[i]] + el[i]
  }
  dist[1:Nt]
}
