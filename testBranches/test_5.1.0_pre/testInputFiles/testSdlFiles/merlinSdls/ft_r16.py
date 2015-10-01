#!/usr/bin/env python
#
# Copyright 2009-2015 Sandia Corporation. Under the terms
# of Contract DE-AC04-94AL85000 with Sandia Corporation, the U.S.
# Government retains certain rights in this software.
#
# Copyright (c) 2009-2015, Sandia Corporation
# All rights reserved.
#
# This file is part of the SST software package. For license
# information, see the LICENSE file in the top level directory of the
# distribution.

import sst
from sst.merlin import *

if __name__ == "__main__":

    topo = topoFatTree()
    endPoint = TestEndPoint()

    sst.merlin._params["fattree:shape"] = "8,8:8,8:16"
    sst.merlin._params["link_bw"] = "8GB/s"
    sst.merlin._params["link_lat"] = "10ns"
    sst.merlin._params["flit_size"] = "32B"
    sst.merlin._params["xbar_bw"] = "8GB/s"
    sst.merlin._params["input_latency"] = "0ns"
    sst.merlin._params["output_latency"] = "0ns"
    sst.merlin._params["input_buf_size"] = "8kB"
    sst.merlin._params["output_buf_size"] = "8kB"
    
    topo.prepParams()
    endPoint.prepParams()
    topo.setEndPoint(endPoint)
    topo.build()
    
