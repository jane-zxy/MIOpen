/*******************************************************************************
 *
 * MIT License
 *
 * Copyright (c) 2019 Advanced Micro Devices, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 *******************************************************************************/
#include "conv_common.hpp"

template <class T>
struct conv2d_driver : conv_driver<T>
{
    conv2d_driver() : conv_driver<T>()
    {
        this->add(this->input_dims, "input");
        this->add(this->weight_tensor_dims, "weights");
        this->add(
            this->batch_size, "batch_size", this->generate_data_limited(this->get_batch_sizes()));
        this->add(this->input_channels,
                  "input_channels",
                  this->generate_data_limited(this->get_input_channels()));
        this->add(this->output_channels,
                  "output_channels",
                  this->generate_data_limited(this->get_output_channels()));
        this->add(this->spatial_dim_elements,
                  "spatial_dim_elements",
                  this->generate_data_limited(this->get_2d_spatial_dims()));
        this->add(this->filter_dims,
                  "filter_dims",
                  this->generate_data_limited(this->get_2d_filter_dims()));
        this->add(this->pads_strides_dilations,
                  "pads_strides_dilations",
                  this->generate_data(this->get_2d_pads_strides_dilations()));
        this->add(this->trans_output_pads,
                  "trans_output_pads",
                  this->generate_data(this->get_2d_trans_output_pads()));
    }
};

int main(int argc, const char* argv[]) { test_drive<conv2d_driver>(argc, argv); }
