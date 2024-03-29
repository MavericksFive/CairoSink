import type { NextApiRequest, NextApiResponse } from 'next'
import { apiVoyagerClient } from '../utils/helpers'
import addresses from '../config/constants'

// type EventItem = CreatedStreamEvent | CancelledStreamEvent | WithdrawnEvent

// type CreatedStreamEvent = {
//     id: string,
//     stream_id: number,
//     owner: string,
//     receiver: string,
//     token: string,
//     amount: number,
//     end_time: Date,
// }

// type CancelledStreamEvent = {
//     id: string,
//     stream_id: number,
//     owner: string,
//     receiver: string,
//     amount: number,
// }

// type WithdrawnEvent = {
//     id: string,
//     user: string,
//     amount: number,
// }

type EventItem = {
    block_number: number
    transaction_number: number
    number: number
    from_address: string
    transactionhash: string
    id: string
    transactionHash: string
}

type EventResponse = {
    items: EventItem[]
    lastPage: number
}

type DataDecoded = {
    name: string
    value: string | string[]
    type: string
}

type EventData = {
    block_number: number
    name: string
    dataDecoded: DataDecoded[]
}

type Message = {
    name: string
    account: string
    messages: string
}

export async function handler(
    req: NextApiRequest,
    res: NextApiResponse,
) {
    const { data: eventsData, status } = await apiVoyagerClient.get('/events', {
        params: {
            contract: addresses.sink,
        },
    })

    const response = eventsData as EventResponse
    const eventIds = response.items
        .sort((a: EventItem, b: EventItem) => b.block_number - a.block_number)
        .map((item) => item.id)

    const messages = await Promise.all(
        eventIds.map(async (id) => {
            try {
                let details: Message = {
                    name: '',
                    messages: '',
                    account: '',
                }
                const { data: eventInfo } = await apiVoyagerClient.get(`/event/${id}`)
                const info = eventInfo as EventData
                const decodedData = info.dataDecoded
                decodedData.map((data) => {
                    // if (Array.isArray(data.value)) {
                    //     if (data.name === 'messages') {
                    //         let fullMsgs = ''
                    //         data.value.forEach((item) => {
                    //             fullMsgs += feltToString(item)
                    //         })
                    //         details.messages = fullMsgs.trim()
                    //     }
                    // } else {
                    //     if (data.name === 'account') {
                    //         details.account = feltToHex(data.value)
                    //     } else if (data.name === 'name') {
                    //         details.name = feltToString(data.value)
                    //     }
                    // }
                })
                return details
            } catch (error) {
                res.status(500).json({ error: 'Unknown server error' })
            }
        }),
    )
    res.status(200).json({ messages })
}