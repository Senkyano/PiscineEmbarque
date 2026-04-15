/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: rihoy <rihoy@student.42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/04/13 17:59:48 by rihoy             #+#    #+#             */
/*   Updated: 2026/04/15 19:56:00 by rihoy            ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <avr/io.h>
#include <util/delay.h>

int	main(void)
{
	DDRB = (1 << PORTB0); // mode output que sur portb0
	DDRD &= ~(1 << PORTD2); // inversement de bit 
	while (1)
	{
		if (!(PIND & (1 << PORTD2))) // appui du bouton
			PORTB |= (1 << PORTB0);
		else
			PORTB &= ~(1 << PORTB0);
	}
	return (0);
}
