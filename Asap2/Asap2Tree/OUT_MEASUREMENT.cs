﻿using System.Collections.Generic;

namespace Asap2
{
    /// <summary>
    /// References to <see cref="MEASUREMENT"/>s that are defined as the outputs of this <see cref="FUNCTION"/>.
    /// </summary>
    [Base()]
    public class OUT_MEASUREMENT : Asap2Base
    {
        public OUT_MEASUREMENT(Location location) : base(location) { }
        [Element(0, IsList = true, IsArgument = true)]
        public List<string> measurements = new List<string>();
    }
}
