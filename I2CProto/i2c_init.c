/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   i2c_init.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: rihoy <rihoy@student.42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/15 16:34:22 by rihoy             #+#    #+#             */
/*   Updated: 2026/04/15 17:42:01 by rihoy            ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "i2c_protocole.h"

void	i2c_start(t_i2c_struct_t info)
{
	*info.ddr_sda &= ~(1 << info.sda_pin);
	*info.ddr_scl &= ~(1 << info.scl_pin);
	_delay_us(5);
	*info.port_sda &= ~(1 << info.sda_pin);
	*info.ddr_sda |= (1 << info.sda_pin);
	_delay_us(5);
	*info.port_scl &= ~(1 << info.scl_pin);
	*info.ddr_scl |= (1 << info.scl_pin);
	_delay_us(5);
}
