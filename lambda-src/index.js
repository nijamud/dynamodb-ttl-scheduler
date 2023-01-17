const {Kafka} = require('kafkajs')
const kafka = new Kafka({
    brokers: [
        'broker:29092',
    ],
    ssl: false,
})

exports.handler = async (event) => {
    let start = new Date();
    const producer = kafka.producer()
    await producer.connect();
    const msg = {value: JSON.stringify(event)};
    let res = await producer.send({
        topic: 'newtopic',
        messages: [msg],
    });

    await producer.disconnect();
    let latency = (new Date()) - start;


    return {
        statusCode: 200,
        body: JSON.stringify(
            {
                header: "Pushed this message to Upstash Kafka with KafkaJS!",
                message: msg,
                response: res,
                latency: latency,
            },
            null,
            2
        ),
    };
};