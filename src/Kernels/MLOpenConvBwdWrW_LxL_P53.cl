/*
 * Copyright (c) 2016 AMD Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and/or associated documentation files (the
 * "Materials"), to deal in the Materials without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Materials, and to
 * permit persons to whom the Materials are furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Materials.
 *
 * THE MATERIALS ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * MATERIALS OR THE USE OR OTHER DEALINGS IN THE MATERIALS.
 */


#define _FLOAT					float
#define _FLOAT2					float2
#define _FLOAT4					float4
#define _FLOAT8					float8

#ifndef FLT_MAX
#define FLT_MAX         3.402823466e+38F        /* max value */
#endif

// number of filter taps in the processing wk_item
//#define MLO_WEI_WKITEM 5


#define MLO_N_OUT_HORIZ_READS (MLO_ALIGNED_OUT_SCAN_LN)
#define MLO_OUT_HORIZ_PIX_SZ (MLO_N_OUT_HORIZ_READS * MLO_READ_UNIT)
#define MLO_N_OUT_VERTICAL_READS (MLO_OUT_HEIGHT)
#define MLO_N_OUT_VERT_PROCS (MLO_N_ALIGNED_OUT_SCAN_BLK* MLO_N_OUT_BLK)

// n of of filter blks
#ifndef MLO_WEI_BLK_SZ0
#define MLO_WEI_BLK_SZ0 ((MLO_FILTER_SIZE0 + MLO_WEI_WKITEM -1)/MLO_WEI_WKITEM)
#endif

#define MLO_WEI_BLK_SZ (MLO_FILTER_SIZE1*MLO_WEI_BLK_SZ0)

// n accum tiles along x
#define  MLO_N_ACCUM0 ((MLO_OUT_WIDTH +  MLO_MAX_WEI_BLK_LOOP -1) /  MLO_MAX_WEI_BLK_LOOP)
// n accum tiles along y
#define MLO_N_ACCUM1 (MLO_N_OUT_BLK)
// accum tile size
#define MLO_ACCUM_SZ (MLO_WEI_BLK_SZ)
// total number of weight blocks
#define MLO_N_WEI_BLK (MLO_N_ACCUM1 * MLO_N_ACCUM0 * MLO_WEI_BLK_SZ)

#define MLO_WEI_BLKS_SZ (MLO_N_WEI_BLK * MLO_WEI_WKITEM)

#define MLO_OUT_WEI_EXT_SCAN_BLK (MLO_N_ACCUM0)


#define MLO_WEI_BLKS_LCL_SZ (MLO_WEI_BLKS_SZ * MLO_N_LCL_OUT_MAPS * MLO_N_LCL_IN_MAPS * MLO_N_OUT_PERGROUP)

#define MLO_OUT_BLK_GRP_PIX_SZ (MLO_OUT_HORIZ_PIX_SZ * MLO_N_OUT_VERT_PROCS)
#define MLO_OUT_BLK_GRP_WK_SZ (MLO_OUT_BLK_GRP_PIX_SZ / MLO_READ_UNIT)

#if MLO_OUT_HORIZ_PIX_SZ >  (MLO_OUT_WEI_EXT_SCAN_BLK * MLO_MAX_WEI_BLK_LOOP)
#define MLO_OUT_HORIZ_PIX_EXT_SZ (MLO_OUT_HORIZ_PIX_SZ)
#else
#define MLO_OUT_HORIZ_PIX_EXT_SZ (MLO_OUT_WEI_EXT_SCAN_BLK * MLO_MAX_WEI_BLK_LOOP)
#endif


#define MLO_OUT_BLK_GRP_EXT_PIX_SZ (MLO_OUT_HORIZ_PIX_EXT_SZ * MLO_N_OUT_VERT_PROCS)
#define MLO_OUT_LCL_SZ (MLO_OUT_BLK_GRP_EXT_PIX_SZ)
// LDS OUT SIZE
#define MLO_TOTAL_OUT_LCL_SZ (MLO_N_LCL_BATCHS*MLO_N_LCL_OUT_MAPS*MLO_N_OUT_PERGROUP*MLO_OUT_LCL_SZ)
#if ((MLO_OUT_HEIGHT/MLO_N_ALIGNED_OUT_SCAN_BLK)*MLO_N_ALIGNED_OUT_SCAN_BLK == MLO_OUT_HEIGHT)
#define MLO_BLK_ALIGNED 1
#else
#define MLO_BLK_ALIGNED 0
#endif


// input size depends on output scan length and
// number of output scans 
// this number is constrained by amount or LDS and size of register file.

#define MLO_IN_VERT_READS (MLO_IN_HEIGHT)
#define MLO_IN_LCL_HEIGHT (MLO_IN_VERT_READS + 2 * MLO_FILTER_PAD1)
// there is an assumption that the scanline fits into LDS
#define MLO_N_IN_HORIZ_PIX_READS (MLO_IN_WIDTH) //((MLO_OUT_WIDTH-1)*MLO_FILTER_STRIDE0 + MLO_FILTER_SIZE0 - 2 * MLO_FILTER_PAD0)
#define MLO_N_IN_HORIZ_READS ((MLO_N_IN_HORIZ_PIX_READS + MLO_READ_UNIT - 1) / MLO_READ_UNIT)
#define MLO_IN_N_PIXS_OFF  (MLO_N_IN_HORIZ_READS*MLO_READ_UNIT - MLO_N_IN_HORIZ_PIX_READS)
// assum the input scan + 2 pads fit into LDS
#define MLO_IN_LCL_WIDTH (MLO_N_IN_HORIZ_READS * MLO_READ_UNIT + 2 * MLO_FILTER_PAD0)
#define MLO_IN_BLK_GRP_PIX_SZ (MLO_IN_LCL_WIDTH * MLO_IN_LCL_HEIGHT)
#define MLO_IN_BLK_GRP_WK_SZ (MLO_IN_BLK_GRP_PIX_SZ/MLO_READ_UNIT)
#define MLO_IN_LCL_SZ (MLO_IN_BLK_GRP_PIX_SZ)
// LDS IN SIZE
#define MLO_TOTAL_IN_LCL_SZ (MLO_N_LCL_BATCHS*MLO_N_LCL_IN_MAPS*MLO_IN_LCL_SZ)

#if (MLO_TOTAL_OUT_LCL_SZ + MLO_TOTAL_IN_LCL_SZ) > (MLO_WEI_BLKS_LCL_SZ)
#define MLO_LCL_SZ (MLO_TOTAL_OUT_LCL_SZ + MLO_TOTAL_IN_LCL_SZ)
#else
#define MLO_LCL_SZ (MLO_WEI_BLKS_LCL_SZ)
#endif


#define MLO_HW_WAVE_ID_SETTING 0

#if MLO_HW_WAVE_ID_SETTING
extern __attribute__((const)) uint __hsail_get_dynwave_id(void);
inline int getWaveId()
{
	int wave_id = 0;

	wave_id = __hsail_get_dynwave_id();
	wave_id = wave_id & MLO_N_PHYS_WAVES_MASK;
	return(wave_id);
}
#else
inline int getWaveId()
{
	int wave_id = 0;

	wave_id = (get_local_id(0) >> MLO_LG2_PHYS_WAVE_SZ);

	return(wave_id);
}
#endif

inline int gePhysLocalId()
{
	int lcl_wave_id = get_local_id(0) - ((get_local_id(0) >> MLO_LG2_PHYS_WAVE_SZ) << MLO_LG2_PHYS_WAVE_SZ);
	return(lcl_wave_id);
}

inline int iDiv(int v, int d)
{
	int r = (int)((float)v / d + 0.00001f);
	return(r);
}

inline int iMod(int v, int u, int d)
{
	int r = v - mul24((int)u, (int)d);
	return(r);
}

inline void ReduceKernel(__local _FLOAT * lcl_blob, _FLOAT *weights_accum, int lcl_id, int scan_lcl, int sum_stride, int unit_len, bool debug)
{
	for (int j = (sum_stride >> 1); j > 0; j >>= 1)
	{
		barrier(CLK_LOCAL_MEM_FENCE);
		if (scan_lcl < j)
		{
			for (int i = 0; i < unit_len; ++i)
			{

				weights_accum[i] += lcl_blob[(lcl_id + j) * unit_len + i];

				lcl_blob[lcl_id * unit_len + i] = weights_accum[i];
			}

		}
	}
}

inline void  Kahan_summation(_FLOAT *sum, _FLOAT * c, _FLOAT v)
{
	_FLOAT y = v - *c;    //So far, so good: c is zero.
	_FLOAT t = *sum + y;         //Alas, sum is big, y small, so low-order digits of y are lost.
	*c = (t - *sum) - y;   //(t - sum) recovers the high-order part of y; subtracting y recovers -(low part of y)
	*sum = t;             //Algebraically, c should always be zero. Beware eagerly optimising compilers!
}

inline void  Kahan_summation_tricked(_FLOAT *sum, _FLOAT * c, _FLOAT v, _FLOAT mod)
{
	_FLOAT y = v - *c;    //So far, so good: c is zero.
	_FLOAT t = *sum + y;         //Alas, sum is big, y small, so low-order digits of y are lost.
	*c = (t - *sum) * mod - y;   //(t - sum) recovers the high-order part of y; subtracting y recovers -(low part of y)
	*sum = t;             //Algebraically, c should always be zero. Beware eagerly optimising compilers!
}


inline void Kahan_summation2(_FLOAT *sum, _FLOAT *c, _FLOAT *v, int n)
{
	for (int i = 0; i < n; ++i)
	{
		_FLOAT y = v[i] - c[i];    //So far, so good: c is zero.
		_FLOAT t = sum[i] + y;         //Alas, sum is big, y small, so low-order digits of y are lost.
		c[i] = (t - sum[i]) - y;   //(t - sum) recovers the high-order part of y; subtracting y recovers -(low part of y)
		sum[i] = t;             //Algebraically, c should always be zero. Beware eagerly optimising compilers!
	}
}

/*********************************************************************************************************
// wrw algorithm for large filters
// idea:
// split filter taps into sub-tiles along x and y axis with number of tap groups muliples of stride or 1
// for example
// the 5x10 filter has been split into 10 sub-tiles 1x5 each, 1 tap in y direction and 5 taps in x direction.
// those horizontal taps are 0, 2, 4, 6, 8 and 1, 3, 5, 7, 9
// a single vertical tap is 0 or 1 or 2 or 3 or 4.
// one may say sub-tiles are indexed by a vertical tap.
// the partial sum has been calculated into those 10 sub-tiles in parallel.
// the full filter has been calulated by reducing all sub-tiles into a single filter per group.
// teh accumulation has been done over all pixels of several outputs being shared with a single input.
// the accuulation has been done per batch.
//
// the total reduction over all batches has been doesn a separete kerenel.
//
// alg
//
//		until end of output map (MLO_N_OUT_BLK)
//			load input map block in LDS
//			load output maps in LDS
//          for j in output scans
//				for i in output scan interval
//                  accumulate the weights into sub-tiles
//
//		reduce sub-tiles into a single filter for each output
//		write accululated weights
//
// group layout
// 0 - n waves * wave size (n_waves has been defined by host)
// 1 - input channel index
// 2 - output channel/batch index
//
//
// for each batch
//	 accumulate all weights per input/output pair


**********************************************************************************************************/

__attribute__((reqd_work_group_size(MLO_GRP_SZ0, MLO_GRP_SZ1, MLO_GRP_SZ2)))
__kernel void MLOpenCvBwdWrW(
	const __global _FLOAT * top_df,
	const __global _FLOAT * bot,
	__global _FLOAT * weights_df,
#if MLO_CONV_BIAS
	__global _FLOAT * bias_df,
#endif
	_FLOAT padding_val
)
{

	// input/output tiles + reduce buffer

	__local _FLOAT lcl[(MLO_LCL_SZ)];
	__local _FLOAT * lcl_bot = lcl;
	__local _FLOAT * lcl_top = lcl + MLO_TOTAL_IN_LCL_SZ;


	// guarnteeing an uniformity over a wave
	int wave_id = getWaveId();

	int c_idx_base = get_group_id(1); // input map index base

	int o_idx_base = iDiv(get_group_id(2), (MLO_BATCH_SZ / (MLO_N_BATCH_LOOPS*MLO_N_LCL_BATCHS))); // output map index base
	int ib_base = iMod(get_group_id(2), o_idx_base, (MLO_BATCH_SZ / (MLO_N_BATCH_LOOPS*MLO_N_LCL_BATCHS)));

	int ib = ib_base*MLO_N_LCL_BATCHS;

	int c_idx = c_idx_base * MLO_N_LCL_IN_MAPS; // input map index

	int o_idx = o_idx_base * (MLO_N_OUT_BLK_GRP * MLO_N_LCL_OUT_MAPS * MLO_N_OUT_PERGROUP); // output map index

	int gbl_in_off = c_idx * MLO_IN_CHANNEL_STRIDE + ib * MLO_IN_BATCH_STRIDE;
	int gbl_out_off = o_idx * MLO_OUT_CHANNEL_STRIDE + ib * MLO_OUT_BATCH_STRIDE;


	int lcl_id = get_local_id(0);

// index of group output split
	 int o_grp = iDiv(lcl_id, MLO_N_WEI_BLK);
// lcl_id inside output split
	int lcl_id_o = iMod(lcl_id, o_grp, MLO_N_WEI_BLK);
// weight tile id
	int w_blk_idx = iDiv(lcl_id_o, MLO_WEI_BLK_SZ);
// y weight block position
	int w_blk1 = iDiv(w_blk_idx, MLO_N_ACCUM0);
// x weight block position
	int w_blk0 = iMod(w_blk_idx, w_blk1, MLO_N_ACCUM0);

// weight index
	int w_idx = iMod(lcl_id_o, w_blk_idx, MLO_WEI_BLK_SZ);
// weight y
	int w_y = iDiv(w_idx, MLO_WEI_BLK_SZ0);
// weight starting x
	int w_x0 = iMod(w_idx, w_y, MLO_WEI_BLK_SZ0);

	__private _FLOAT pvt_accum[(MLO_N_OUT_BLK_GRP * MLO_N_LCL_OUT_MAPS * MLO_N_LCL_IN_MAPS * MLO_WEI_WKITEM)];


	for (int i = 0; i < (MLO_N_OUT_BLK_GRP * MLO_N_LCL_OUT_MAPS * MLO_N_LCL_IN_MAPS * MLO_WEI_WKITEM); ++i)
	{
		pvt_accum[i] = 0;
	}


	// zero out LDS
	for (int i = lcl_id; i < (MLO_LCL_SZ); i += MLO_GRP_SZ)
	{
		lcl[i] = 0;
	}

//	barrier(CLK_LOCAL_MEM_FENCE);




#if 1
	// over all batches

	for (int b = 0;
		b < MLO_N_BATCH_LOOPS;
		++b,
		gbl_in_off += MLO_N_LCL_BATCHS*MLO_IN_BATCH_STRIDE,
		gbl_out_off += MLO_N_LCL_BATCHS*MLO_OUT_BATCH_STRIDE
		)
	{
		int in_y = 0;
		int out_y = 0;

		// prefetch MLO_FILTER_STRIDE1 - MLO_FILTER_PAD1 input scans
		__private _FLOAT in_rd_data[MLO_READ_UNIT];

		int gbl_in_scan_off = gbl_in_off;
		int gbl_out_scan_off = gbl_out_off;
		// over all out blocks
		// processing per MLO_N_ALIGNED_OUT_SCAN_BLK output scans


		barrier(CLK_LOCAL_MEM_FENCE);




		for (int p4 = lcl_id; p4 < MLO_N_LCL_IN_MAPS * MLO_N_IN_HORIZ_READS * MLO_IN_VERT_READS;
			p4 += MLO_GRP_SZ)
		{
			int c_scan = 0;

			int c = 0;
			int p4_t = p4;
#if MLO_N_LCL_IN_MAPS > 1
			c = iDiv(p4, (MLO_N_IN_HORIZ_READS * MLO_IN_VERT_READS));
			p4_t = iMod(p4, c, (MLO_N_IN_HORIZ_READS*MLO_IN_VERT_READS));
			if (c_idx + c < MLO_N_INPUTS)
#endif

			{
				c_scan = iDiv(p4_t, MLO_N_IN_HORIZ_READS);

				int c_pix4 = iMod(p4_t, c_scan, MLO_N_IN_HORIZ_READS);



				*(MLO_READ_TYPE*)in_rd_data = *(MLO_READ_TYPE*)&bot[gbl_in_scan_off + c*MLO_IN_CHANNEL_STRIDE + c_scan * MLO_IN_STRIDE + c_pix4*MLO_READ_UNIT];

#if MLO_IN_N_PIXS_OFF > 0
				if (c_pix4 == MLO_N_IN_HORIZ_READS - 1)
				{
					for (int i = MLO_READ_UNIT - 1; i >= MLO_READ_UNIT - MLO_IN_N_PIXS_OFF; --i)
					{
						in_rd_data[i] = 0;
					}

				}
#endif

				for (int i = 0; i < MLO_READ_UNIT; ++i)
				{
					int lcl_in_off = c*MLO_IN_LCL_SZ + (c_scan + MLO_FILTER_PAD1)*MLO_IN_LCL_WIDTH + MLO_FILTER_PAD0 + c_pix4*MLO_READ_UNIT + i;
					lcl_bot[lcl_in_off] = in_rd_data[i];
#if 0
					if (c_idx + c == 1 && p4_t == 0)
					{
						printf("K:g: %d %f\n",
							lcl_in_off,
							lcl_bot[lcl_in_off]
						);
					}
#endif
				}
			}

		} // for (int p4 = lcl_id; p4 < MLO_N_LCL_IN_MAPS * MLO_N_IN_HORIZ_READS * MLO_IN_VERT_READS;

		gbl_out_scan_off = gbl_out_off + mul24(out_y, MLO_OUT_STRIDE);

		// over all outputs groups
		// MLO_N_OUT_BLK_GRP outputs reuse the same input
		// each output blk is MLO_N_LCL_OUT_MAPS outputs
		// MLO_N_LCL_OUT_MAPS nuber is restricted by LDS size

		int gbl_out_scan_off1 = gbl_out_scan_off;
		for (int og = 0; og < MLO_N_OUT_BLK_GRP
			; ++og, gbl_out_scan_off1 += MLO_N_LCL_OUT_MAPS* MLO_N_OUT_PERGROUP* MLO_OUT_CHANNEL_STRIDE)
		{

			// fetch output. MLO_N_ALIGNED_OUT_SCAN_BLK output scans, each of size MLO_N_OUT_HORIZ_READS

			__private _FLOAT out_rd_data[MLO_READ_UNIT];

			for (int oo_p4 = lcl_id; oo_p4 < (MLO_N_LCL_OUT_MAPS* MLO_N_OUT_PERGROUP*MLO_N_OUT_VERTICAL_READS*MLO_N_OUT_HORIZ_READS);
				oo_p4 += MLO_GRP_SZ)
			{
				int o = iDiv(oo_p4, (MLO_N_OUT_VERTICAL_READS*MLO_N_OUT_HORIZ_READS));
				int o_pX4 = iMod(oo_p4, o, (MLO_N_OUT_VERTICAL_READS*MLO_N_OUT_HORIZ_READS));
				int o_scan = iDiv(o_pX4, MLO_N_OUT_HORIZ_READS);
				int o_pix4 = iMod(o_pX4, o_scan, MLO_N_OUT_HORIZ_READS);
				*(MLO_READ_TYPE*)out_rd_data
					= *(MLO_READ_TYPE*)&top_df[gbl_out_scan_off1 + o*MLO_OUT_CHANNEL_STRIDE + o_scan * MLO_OUT_STRIDE + o_pix4*MLO_READ_UNIT];

				// scan has been fetch by 4
				// here the non-multiple of 4 scan has been handled
				// also makes sure the input garbage hs been multipled by 0
#if MLO_OUT_SCAN_NOT_DIVBY4
				if (o_pix4 == (MLO_N_OUT_HORIZ_READS - 1))
				{
					for (int i = MLO_READ_UNIT - 1; i >= MLO_READ_UNIT - MLO_OUT_N_PIXS_OFF; --i)
					{
						out_rd_data[i] = 0;
					}
				}
#endif


				// write into LDS with MLO_OUT_HORIZ_PIX_EXT_SZ stride to zero out weights block overshoot
										//						*(MLO_READ_TYPE*)&lcl_top[o * MLO_OUT_LCL_SZ + o_scan * MLO_OUT_HORIZ_PIX_EXT_SZ + o_pix4*MLO_READ_UNIT] = *(MLO_READ_TYPE*)out_rd_data;
										//

				for (int i = 0; i < MLO_READ_UNIT; ++i)
				{
					lcl_top[o * MLO_OUT_LCL_SZ + o_scan * MLO_OUT_HORIZ_PIX_EXT_SZ + o_pix4*MLO_READ_UNIT + i] = out_rd_data[i];
				}

			} //	for (int oo_p4 = lcl_id; oo_p4 < (MLO_N_LCL_OUT_MAPS*MLO_N_ALIGNED_OUT_SCAN_BLK*MLO_N_OUT_HORIZ_READS); oo_p4 += MLO_GRP_SZ)

			barrier(CLK_LOCAL_MEM_FENCE);


			// process	
			// algorithm

#if 1
			if (o_grp < MLO_N_OUT_PERGROUP)
			{
				// over all input scans in LDS
				for (int j = 0; j < MLO_N_ALIGNED_OUT_SCAN_BLK/* && (w_blk1 * MLO_N_ALIGNED_OUT_SCAN_BLK + j) < MLO_N_OUT_VERTICAL_READS*/; ++j)
				{

					// prefetch proper inputs pixels.
					// they are MLO_WEI_BLK_SZ0 apart taps of the filter

					_FLOAT i_vals[MLO_N_LCL_IN_MAPS*MLO_WEI_WKITEM];

					for (int c = 0; c < MLO_N_LCL_IN_MAPS; ++c)
					{

						for (int w = 0; w < (MLO_WEI_WKITEM - (MLO_FILTER_STRIDE0 / MLO_WEI_BLK_SZ0)); ++w)
						{
							int w_x = w_x0 + w*MLO_WEI_BLK_SZ0;
							int i_off = c*MLO_IN_LCL_SZ
								+ (w_blk1 * MLO_N_ALIGNED_OUT_SCAN_BLK + j + w_y) * MLO_IN_LCL_WIDTH
								+ (w_blk0*MLO_MAX_WEI_BLK_LOOP + 0)
								+ w_x;
							_FLOAT i_val = lcl_bot[i_off];

							i_vals[c*MLO_WEI_WKITEM + w] = i_val;

						}
					}


					// if we overshoot the scanline
					// out data will be 0 by initial setting
					for (int i = 0; i < MLO_MAX_WEI_BLK_LOOP; ++i)
					{

						for (int c = 0; c < MLO_N_LCL_IN_MAPS; ++c)
						{
							// read the current input pixel
							for (int w = (MLO_WEI_WKITEM - (MLO_FILTER_STRIDE0 / MLO_WEI_BLK_SZ0)); w < MLO_WEI_WKITEM; ++w)
							{
								int w_x = w_x0 + w* MLO_WEI_BLK_SZ0;
								int i_off = c*MLO_IN_LCL_SZ
									+ (w_blk1 * MLO_N_ALIGNED_OUT_SCAN_BLK + j + w_y) * MLO_IN_LCL_WIDTH
									+ (w_blk0 * MLO_MAX_WEI_BLK_LOOP + i)
									+ w_x;
								_FLOAT i_val = lcl_bot[i_off];

								i_vals[c*MLO_WEI_WKITEM + w] = i_val;
							}
						}
						// for each output accumulate a proper filter tap
						for (int o = 0; o < MLO_N_LCL_OUT_MAPS; ++o)
						{

							// read with MLO_OUT_HORIX_PIX_EXT_SZ stride
							_FLOAT o_val
								= lcl_top[(o_grp*MLO_N_OUT_PERGROUP + o)*MLO_OUT_LCL_SZ + (w_blk1 * MLO_N_ALIGNED_OUT_SCAN_BLK + j) * MLO_OUT_HORIZ_PIX_EXT_SZ + (w_blk0 * MLO_MAX_WEI_BLK_LOOP + i)];


							_FLOAT i_val;
							for (int w = 0; w < MLO_WEI_WKITEM; ++w)
							{

								for (int c = 0; c < MLO_N_LCL_IN_MAPS; ++c)
								{
									i_val = i_vals[c*MLO_WEI_WKITEM + w];

									pvt_accum[((og * MLO_N_LCL_OUT_MAPS + o) *MLO_N_LCL_IN_MAPS + c) * MLO_WEI_WKITEM + w] += i_val * o_val;
#if 0
									int w_x = w_x0 + w*MLO_WEI_BLK_SZ0;
									if (i_val * o_val != 0 && o_grp < MLO_N_OUT_PERGROUP && ib == 0 && c_idx + c == 1
										&& o_idx + og*MLO_N_LCL_OUT_MAPS + o == 1 && w_y == 1 && w_x == 0)
									{
										int i_off = c*MLO_IN_LCL_SZ
											+ (w_blk1 * MLO_N_ALIGNED_OUT_SCAN_BLK + j + w_y) * MLO_IN_LCL_WIDTH
											+ (w_blk0*MLO_MAX_WEI_BLK_LOOP + i)
											+ w_x;
										printf("K:a: %d %d %d  %f %f %f %f\n",
											lcl_id,
											(w_blk1 * MLO_N_ALIGNED_OUT_SCAN_BLK + j),
											(w_blk0 * MLO_MAX_WEI_BLK_LOOP + i),
											pvt_accum[((og * MLO_N_LCL_OUT_MAPS + o) *MLO_N_LCL_IN_MAPS + c) * MLO_WEI_WKITEM + w],
											i_val * o_val,
											i_val,
											o_val
										);
									}
#endif
								}


							} // for (/*int w = 0*/; w < MLO_WEI_WKITEM; ++w)

						} // for (int o = 0; o < MLO_N_LCL_OUT_MAPS; ++o)


						for (int c = 0; c < MLO_N_LCL_IN_MAPS; ++c)
						{
							for (int w = 0; w < (MLO_WEI_WKITEM - (MLO_FILTER_STRIDE0 / MLO_WEI_BLK_SZ0)); ++w)
							{
								i_vals[c*MLO_WEI_WKITEM + w] = i_vals[c*MLO_WEI_WKITEM + w + (MLO_FILTER_STRIDE0 / MLO_WEI_BLK_SZ0)];

							}
						}
					} // for (int i = 0; i < MLO_OUT_WEI_SCAN_BLK; ++i)
				} // for (int j = 0; j < MLO_N_ALIGNED_OUT_SCAN_BLK; ++j)
#else
			for (int o = 0; o < MLO_N_LCL_OUT_MAPS; ++o)
			{
				for (int w = 0; w < MLO_WEI_WKITEM; ++w)
				{
					pvt_accum[(og * MLO_N_LCL_OUT_MAPS + o) * MLO_WEI_WKITEM + w] = lcl_top[(og * MLO_N_LCL_OUT_MAPS + o)] * lcl_bot[w];
				}
			}
#endif			
			} //	if (o_grp < MLO_N_OUT_PERGROUP)

		} // for(; og < (MLO_N_OUT_BLK_GRP; ++og )


	} // for (int b = 0;


#endif

// send it out
	  // inputs are outputs
	int wei_df_off = ((ib * MLO_N_OUTPUTS + o_idx) * (int)MLO_WEI_BATCH_STRIDE)
		// this input channel
		+ mul24(c_idx, (int)MLO_WEI_CHANNEL_STRIDE);

	int wei_lcl_off = 0;
	_FLOAT final_sum = 0;


// save in lcl and orgnize in a proper order
	// outputs
	//	  input (if available)
	//		 filter size1
	//	       filter size0

// TO DO:: DEPENDING ON THE GROUP SIZE
	for (int og = 0; og < MLO_N_OUT_BLK_GRP; ++og)
	{

		barrier(CLK_LOCAL_MEM_FENCE);

		for (int o = 0; o < MLO_N_LCL_OUT_MAPS && lcl_id < MLO_N_OUT_PERGROUP * MLO_N_WEI_BLK; ++o)
		{
			for (int c = 0; c < MLO_N_LCL_IN_MAPS; ++c)
			{

				for (int w = 0; w < MLO_WEI_WKITEM; ++w)
				{
					// save "virtual" filter table
					int w_x = w_x0 + w*MLO_WEI_BLK_SZ0;
					wei_lcl_off = o_grp * MLO_WEI_BLKS_SZ +
						((o*MLO_N_LCL_IN_MAPS + c) * MLO_N_WEI_BLK + w_blk_idx * MLO_WEI_BLK_SZ)* MLO_WEI_WKITEM + w_y * (MLO_WEI_BLK_SZ0 *MLO_WEI_WKITEM) + w_x;
					lcl[wei_lcl_off] = pvt_accum[((og * MLO_N_LCL_OUT_MAPS + o) *MLO_N_LCL_IN_MAPS + c) *MLO_WEI_WKITEM + w];

#if 0
					if (o_grp < MLO_N_OUT_PERGROUP && /*ib == 0 && */c_idx + c == 0 && o_idx + og*MLO_N_LCL_OUT_MAPS + o == 0 && w_y == 0 && w_x == 0)
					{

						printf("K:s: %d %d %d %f\n",
							ib,
							lcl_id,
							wei_lcl_off,
							pvt_accum[((og * MLO_N_LCL_OUT_MAPS + o) *MLO_N_LCL_IN_MAPS + c) *MLO_WEI_WKITEM + w]
						);

					}
#endif

				}
			}

		}

		barrier(CLK_LOCAL_MEM_FENCE);

		// read into real filter table

		for(int l = lcl_id; l < (MLO_N_OUT_PERGROUP * MLO_N_LCL_OUT_MAPS *MLO_N_LCL_IN_MAPS *MLO_WEI_CHANNEL_STRIDE); l+=MLO_GRP_SZ)
		{


			int o = iDiv(l, MLO_N_LCL_IN_MAPS *MLO_WEI_CHANNEL_STRIDE);
			int c_w = iMod(l, o, MLO_N_LCL_IN_MAPS *MLO_WEI_CHANNEL_STRIDE);
			int c = iDiv(c_w, MLO_WEI_CHANNEL_STRIDE);
			int wei_i = iMod(c_w, c, MLO_WEI_CHANNEL_STRIDE);
			int wei_i_y = iDiv(wei_i, (MLO_FILTER_SIZE0));
			int wei_i_x = iMod(wei_i, wei_i_y, (MLO_FILTER_SIZE0));
			// send it out
			// inputs are outputs
			int wei_df_off = ((ib * MLO_N_OUTPUTS + o_idx) * (int)MLO_WEI_BATCH_STRIDE)
				+ (og *  MLO_N_OUT_PERGROUP * MLO_N_LCL_OUT_MAPS + o) * MLO_WEI_BATCH_STRIDE
				// this input channel
				+ mul24(c_idx + c, (int)MLO_WEI_CHANNEL_STRIDE);

			final_sum = 0;
			for (int i = 0; i < (MLO_N_ACCUM1 * MLO_N_ACCUM0); ++i)
			{
				int bot_off = ((o*MLO_N_LCL_IN_MAPS + c) * MLO_N_WEI_BLK + i *  MLO_WEI_BLK_SZ)* MLO_WEI_WKITEM + wei_i_y * (MLO_WEI_BLK_SZ0 *MLO_WEI_WKITEM) + wei_i_x;
				final_sum += lcl_bot[bot_off];

#if 0
				if (/*ib == 0 && */c_idx == 0 && o_idx + og*MLO_N_LCL_OUT_MAPS + o == 0 && wei_i_y == 0 && wei_i_x == 0)
				{

					printf("K:a2: %d %d %d %f %f\n",
						ib,
						lcl_id,
						bot_off,
						final_sum,
						lcl_bot[bot_off]
					);

				}
#endif
			}

#if 1

			weights_df[wei_df_off + wei_i] = final_sum; //lcl_bot[lcl_id]; //
#if 1
			if (/*ib == 0 && */c_idx + c == 0 && o_idx + og*MLO_N_LCL_OUT_MAPS + o == 0 && wei_i_y == 0 && wei_i_x == 0)
			{

				printf("K:o: %d %d %f\n",
					ib,
					lcl_id,
					wei_df_off + wei_i,
					weights_df[wei_df_off + wei_i]
				);

			}
#endif


#else
			_FLOAT t_accum = 0;

			for (int og = 0; og < MLO_N_OUT_BLK_GRP; ++og)
			{
				for (int o = 0; o < MLO_N_LCL_OUT_MAPS; ++o)
				{
					for (int w = 0; w < MLO_WEI_WKITEM; ++w)
					{
						t_accum += pvt_accum[(og * MLO_N_LCL_OUT_MAPS + o) * MLO_WEI_WKITEM + w];
					}
				}
			}

			weights_df[lcl_id] = t_accum;
#endif


		}

	//	barrier(CLK_LOCAL_MEM_FENCE);

	} // for(int og = 0; og < MLO_N_OUT_BLK_GRP; ++og)



}


// final reduction kernel
// add filters over batches
__attribute__((reqd_work_group_size(MLO_UT_GRP_SZ0, 1, 1)))
__kernel void MLOpenCvBwdWrW_rdc(
	const __global _FLOAT * weight_df_tmp,
	__global _FLOAT * weights_df
)
{
	int gbl_id = get_global_id(0);
	int wei_idx0 = gbl_id * MLO_UT_READ_UNIT;

	int wei_blk_idx = iDiv(wei_idx0, MLO_WEI_CHANNEL_STRIDE);
	int wei_idx = iMod(wei_idx0, wei_blk_idx, MLO_WEI_CHANNEL_STRIDE);

	_FLOAT pvt_accum_wei[MLO_UT_READ_UNIT];
	for (int i = 0; i < MLO_UT_READ_UNIT; ++i)
	{
		pvt_accum_wei[i] = 0;
	}

	int batch_loop = (MLO_BATCH_SZ + (MLO_N_BATCH_LOOPS*MLO_N_LCL_BATCHS) - 1) / (MLO_N_BATCH_LOOPS*MLO_N_LCL_BATCHS);
	for (int i = 0; i < batch_loop; ++i)
	{
		*(MLO_UT_READ_TYPE*)pvt_accum_wei
			+= *(MLO_UT_READ_TYPE*)&weight_df_tmp[(wei_blk_idx * MLO_WEI_CHANNEL_STRIDE + i* MLO_N_OUTPUTS*MLO_WEI_BATCH_STRIDE)  + wei_idx];
	}

	*(MLO_UT_READ_TYPE*)&weights_df[wei_idx0] = *(MLO_UT_READ_TYPE*)pvt_accum_wei;

}